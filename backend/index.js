import express from "express";
import cors from "cors";
import axios from "axios";
import dotenv from "dotenv";
import multer from "multer";
import path from "path";
import fs from "fs";

import "./config/firebase.js";

import { db,auth } from "./config/firebase.js";

import matcheventsRouter from "./routes/match_events.routes.js";
import authRoutes from "./routes/auth.routes.js";
import { authMiddleware } from "./middleware/auth.middleware.js";
import {
  requireSuperAdmin,
  requireMatchAdmin,
  requireApprovedUser,
} from "./middleware/roles.middleware.js";

// Setup multer for file uploads
const uploadDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.use(authRoutes);
app.use(matcheventsRouter);




// ================================
// ✅ AI HELPER FUNCTION (MUST BE ABOVE ROUTES)
// ================================
async function generateCommentary(event) {
  const prompt = `Badminton commentary: ${event.player} hits a ${event.shot}. Commentary:`;

  try {
    const response = await axios.post(
      "https://api-inference.huggingface.co/pipeline/text-generation/gpt2",
      {
        inputs: prompt,
        parameters: {
          max_new_tokens: 40,
          temperature: 0.9
        }
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.HF_API_KEY}`,
          "Content-Type": "application/json"
        }
      }
    );

    return response.data[0].generated_text;
  } catch (err) {
    console.error("HF error:", err.response?.data || err.message);
    throw new Error("HF inference failed");
  }
}

// ================================
// ✅ EVENT ROUTE (USES THE FUNCTION)
// ================================
app.post("/event", async (req, res) => {
  const event = req.body;

  if (!event.event_type || !event.player || !event.match_id) {
    return res.status(400).json({ error: "Invalid event data" });
  }

  try {
    const commentary = await generateCommentary(event);

    const enrichedEvent = {
      ...event,
      commentary,
    };

    await db
      .ref(`matches/${event.match_id}/events`)
      .push(enrichedEvent);

    console.log("Event + commentary pushed to Firebase");

    res.json({
      status: "Event received",
      commentary,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Firebase error" });
  }
});

async function collegeExists(college_id) {
  const snapshot = await db.ref(`colleges/${college_id}`).once("value");
  return snapshot.exists();
}

async function adminAuth(req, res, next) {
  const adminId = req.headers["x-admin-id"];

  if (!adminId) {
    return res.status(401).json({ error: "Admin ID missing" });
  }

  const snapshot = await db.ref(`admins/${adminId}`).once("value");

  if (!snapshot.exists()) {
    return res.status(401).json({ error: "Invalid admin ID" });
  }

  req.admin = snapshot.val(); // attach admin data
  next();
}

// function requireSuperAdmin(req, res, next) {
//   if (req.admin.role !== "super_admin") {
//     return res.status(403).json({ error: "Super admin access required" });
//   }
//   next();
// }

// function requireMatchAdmin(req, res, next) {
//   if (req.admin.role !== "match_admin") {
//     return res.status(403).json({ error: "Match admin access required" });
//   }
//   next();
// }



// app.post("/system/create-college", async (req, res) => {
//   const { name, code } = req.body;

//   if (!(await collegeExists(college_id))) {
//   return res.status(400).json({ error: "College does not exist" });
//   }


//   if (!name || !code) {
//     return res.status(400).json({ error: "Invalid college data" });
//   }

//   const collegeRef = db.ref("colleges").push();
//   const collegeId = collegeRef.key;

//   await collegeRef.set({
//     college_id: collegeId,
//     name,
//     code,
//     created_at: Date.now()
//   });

//   res.json({
//     message: "College created",
//     college_id: collegeId
//   });
// });

// app.post("/system/create-admin", async (req, res) => {
//   const { name, college_id } = req.body;

//   if (!(await collegeExists(college_id))) {
//   return res.status(400).json({ error: "College does not exist" });
// }


//   if (!name || !college_id) {
//     return res.status(400).json({ error: "Invalid admin data" });
//   }

//   // 1️⃣ Check if super admin already exists for this college
//   const adminsSnapshot = await db.ref("admins").once("value");
//   let superAdminExists = false;

//   adminsSnapshot.forEach((child) => {
//     const admin = child.val();
//     if (
//       admin.college_id === college_id &&
//       admin.role === "super_admin"
//     ) {
//       superAdminExists = true;
//     }
//   });

//   // 2️⃣ Decide role
//   const role = superAdminExists ? "match_admin" : "super_admin";

//   // 3️⃣ Create admin
//   const adminRef = db.ref("admins").push();
//   const adminId = adminRef.key;

//   await adminRef.set({
//     admin_id: adminId,
//     name,
//     role,
//     college_id,
//     created_at: Date.now()
//   });

//   res.json({
//     message: "Admin created",
//     admin_id: adminId,
//     assigned_role: role
//   });
// });

// app.post("/system/create-user", async (req, res) => {
//   const { name, college_id } = req.body;

//   const userRef = db.ref("users").push();
//   const userId = userRef.key;

//   if (!(await collegeExists(college_id))) {
//   return res.status(400).json({ error: "College does not exist" });
// }


//   await userRef.set({
//     user_id: userId,
//     name,
//     role: "user",
//     college_id,
//     created_at: Date.now()
//   });

//   res.json({
//     message: "User created",
//     user_id: userId
//   });
// });

// app.post("/system/create-team", async (req, res) => {
//   const { name, college_id, members } = req.body;

//   if (!name || !college_id) {
//     return res.status(400).json({ error: "Invalid team data" });
//   }

//   if (!(await collegeExists(college_id))) {
//   return res.status(400).json({ error: "College does not exist" });
// }

//   const teamRef = db.ref("teams").push();
//   const teamId = teamRef.key;

//   await teamRef.set({
//     team_id: teamId,
//     name,
//     college_id,
//     members: members || [],
//     created_at: Date.now()
//   });

//   res.json({
//     message: "Team created",
//     team_id: teamId
//   });
// });

// app.post("/system/create-match", async (req, res) => {
//   const { college_id, sport, participant_type, participantA, participantB } =
//     req.body;

//     if (!(await collegeExists(college_id))) {
//   return res.status(400).json({ error: "College does not exist" });
// }
//   const ref = db.ref(`matches/${college_id}`).push();
//   await ref.set({
//     match_id: ref.key,
//     sport,
//     participant_type,
//     participantA,
//     participantB,
//     status: "upcoming",
//     created_at: Date.now()
//   });

//   res.json({ message: "Match created", match_id: ref.key });
// });



// app.get(
//   "/admin/tournament/:tournamentId/matches",
//   adminAuth,
//   async (req, res) => {
//     const { tournamentId } = req.params;
//     const { college_id } = req.admin;

//     const snap = await db
//       .ref(`tournaments/${college_id}/${tournamentId}/matches`)
//       .once("value");

//     if (!snap.exists()) return res.json([]);

//     const matchesData = snap.val();
//     const matches = Object.keys(matchesData).map((matchId) => ({
//       matchId,
//       tournamentId,
//       ...matchesData[matchId],
//     }));
//     res.json(matches);
//   }
// );

app.get(
  "/admin/tournament/:tournamentId/matches",
  authMiddleware,
  requireApprovedUser,
  async (req, res) => {
    try {
      const { tournamentId } = req.params;
      const collegeId = req.user.collegeId;

      const snap = await db
        .ref(`tournaments/${collegeId}/${tournamentId}/matches`)
        .once("value");

      if (!snap.exists()) {
        return res.json([]);
      }

      const matchesData = snap.val();

      const matches = Object.keys(matchesData).map((matchId) => ({
        matchId,
        tournamentId,
        ...matchesData[matchId],
      }));

      return res.json(matches);
    } catch (err) {
      console.error("GET TOURNAMENT MATCHES ERROR:", err);
      return res.status(500).json({ error: "Failed to fetch matches" });
    }
  }
);

// app.post(
//   "/admin/tournament/:tournamentId/create-match",
//   adminAuth,
//   async (req, res) => {
//     const { tournamentId } = req.params;
//     const { name, teamA, teamB, court, matchType, sport } = req.body;

//     if (!name || !teamA || !teamB) {
//       return res.status(400).json({ error: "Missing fields" });
//     }

//     const { college_id } = req.admin;

//     const ref = db
//       .ref(`tournaments/${college_id}/${tournamentId}/matches`)
//       .push();

//     const match = {
//       matchId: ref.key,
//       name,
//       teamA,
//       teamB,
//       court,
//       matchType,
//       sport,
//       status: "upcoming",
//       startedAt: null,
//       endedAt: null,
//       createdAt: Date.now(),
//     };

//     await ref.set(match);

//     res.json(match);
//   }
// );

app.post(
  "/admin/tournament/:tournamentId/create-match",
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const { tournamentId } = req.params;
      const { name, teamA, teamB, court, matchType, sport } = req.body;
      const collegeId = req.user.collegeId;

      if (!name || !teamA || !teamB || !court || !matchType || !sport) {
        return res.status(400).json({ error: "Missing required fields" });
      }

      const ref = db.ref(`tournaments/${collegeId}/${tournamentId}/matches`).push();

      const match = {
        matchId: ref.key,
        tournamentId,
        collegeId,
        name,
        teamA,
        teamB,
        court,
        matchType,
        sport,
        status: "upcoming",
        assignAdmin: false,
        assigned_admin: null,
        startedAt: null,
        endedAt: null,
        createdAt: Date.now(),
      };

      await ref.set(match);

      return res.json(match);
    } catch (err) {
      console.error("CREATE MATCH ERROR:", err);
      return res.status(500).json({ error: "Failed to create match" });
    }
  }
);

// app.post(
//   "/admin/tournament/:tournamentId/match/:matchId/assign-admin",
//   adminAuth,
//   async (req, res) => {
//     const { tournamentId, matchId } = req.params;
//     const { adminId, adminName } = req.body;
//     const { college_id } = req.admin;

//     if (!adminId || !adminName) {
//       return res.status(400).json({ error: "Missing admin data" });
//     }

//     const assignPath = `tournaments/${college_id}/${tournamentId}/matches/${matchId}/assigned_admin`;

//     console.log("WRITING TO:", assignPath);

//     await db.ref(assignPath).set({
//       adminId,
//       adminName,
//       assignedAt: Date.now(),
//     });

//     return res.json({
//       message: "Admin assigned successfully",
//       path: assignPath,
//     });
//   }
// );

app.post(
  "/admin/tournament/:tournamentId/match/:matchId/assign-admin",
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const { tournamentId, matchId } = req.params;
      const { adminId, adminName } = req.body;
      const collegeId = req.user.collegeId;

      console.log("ASSIGN ADMIN REQUEST:", {
        tournamentId,
        matchId,
        adminId,
        adminName,
        collegeId,
      });

      if (!adminId || !adminName) {
        return res.status(400).json({ error: "Missing admin data" });
      }

      // ✅ verify selected admin from users collection
      const adminSnap = await db.ref(`users/${adminId}`).once("value");

      if (!adminSnap.exists()) {
        return res.status(404).json({ error: "Match admin not found" });
      }

      const adminData = adminSnap.val();

      console.log("SELECTED MATCH ADMIN:", {
        name: adminData.name,
        role: adminData.role,
        collegeId: adminData.collegeId,
        approvalStatus: adminData.approvalStatus,
      });

      if (adminData.role !== "match_admin") {
        return res.status(400).json({ error: "Selected user is not a match admin" });
      }

      // ✅ FIX: case-insensitive college comparison
      if (
        String(adminData.collegeId || "").trim().toLowerCase() !==
        String(collegeId || "").trim().toLowerCase()
      ) {
        return res.status(403).json({ error: "Cannot assign admin from another college" });
      }

      if (adminData.approvalStatus !== "approved") {
        return res.status(400).json({ error: "Match admin is not approved yet" });
      }

      const matchRef = db.ref(
        `tournaments/${collegeId}/${tournamentId}/matches/${matchId}`
      );

      const matchSnap = await matchRef.once("value");

      if (!matchSnap.exists()) {
        return res.status(404).json({ error: "Match not found" });
      }

      await matchRef.update({
        assignAdmin: true,
        assigned_admin: {
          adminId,
          adminName,
          assignedAt: Date.now(),
        },
      });

      return res.json({
        message: "Admin assigned successfully",
      });
    } catch (err) {
      console.error("ASSIGN MATCH ADMIN ERROR:", err);
      return res.status(500).json({ error: "Failed to assign admin" });
    }
  }
);



// app.post("/system/create-tournament", async (req, res) => {
//   const { name, sport, college_id, mode } = req.body;

//   const ref = db.ref(`tournaments/${college_id}`).push();

//   if (!(await collegeExists(college_id))) {
//   return res.status(400).json({ error: "College does not exist" });
//   }
//   await ref.set({
//     tournament_id: ref.key,
//     name,
//     sport,
//     mode, // manual | automatic
//     created_at: Date.now()
//   });

//   res.json({ message: "Tournament created", tournament_id: ref.key });
// });

// app.post(
//   "/admin/create-tournament",
//   adminAuth,
//   requireSuperAdmin,
//   async (req, res) => {
//     const { name, sport, mode } = req.body;
//     const college_id = req.admin.college_id;

//     if (!name || !sport || !mode) {
//       return res.status(400).json({ error: "Missing required fields" });
//     }

//     const ref = db.ref(`tournaments/${college_id}`).push();

//     const tournament = {
//       tournament_id: ref.key,
//       name,
//       sport,
//       mode,
//       created_at: Date.now(),
//     };

//     await ref.set(tournament);

//     res.json({
//       message: "Tournament created",
//       tournament,
//     });
//   }
// );

app.post(
  "/admin/create-tournament",
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const { name, sport, mode } = req.body;
      const collegeId = req.user.collegeId;

      if (!name || !sport || !mode) {
        return res.status(400).json({ error: "Missing required fields" });
      }

      const ref = db.ref(`tournaments/${collegeId}`).push();

      const tournament = {
        tournament_id: ref.key,
        name,
        sport,
        mode,
        collegeId,
        created_at: Date.now(),
      };

      await ref.set(tournament);

      return res.json({
        message: "Tournament created",
        tournament,
      });
    } catch (err) {
      console.error("CREATE TOURNAMENT ERROR:", err);
      return res.status(500).json({ error: "Failed to create tournament" });
    }
  }
);

// app.get(
//   "/admin/tournaments",
//   adminAuth,
//   requireSuperAdmin,
//   async (req, res) => {
//     const college_id = req.admin.college_id;

//     const snapshot = await db
//       .ref(`tournaments/${college_id}`)
//       .once("value");

//     const tournaments = [];

//     snapshot.forEach((child) => {
//       tournaments.push(child.val());
//     });

//     res.json(tournaments);
//   }
// );

app.get(
  "/admin/tournaments",
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const collegeId = req.user.collegeId;

      const snapshot = await db.ref(`tournaments/${collegeId}`).once("value");

      const tournaments = [];

      if (snapshot.exists()) {
        snapshot.forEach((child) => {
          tournaments.push(child.val());
        });
      }

      return res.json(tournaments);
    } catch (err) {
      console.error("GET TOURNAMENTS ERROR:", err);
      return res.status(500).json({ error: "Failed to fetch tournaments" });
    }
  }
);



// app.post(
//   "/admin/assign-match",
//   adminAuth,
//   requireSuperAdmin,
//   async (req, res) => {
//     const { match_id, match_admin_id } = req.body;
//     const college_id = req.admin.college_id;

//     const matchRef = db.ref(`matches/${college_id}/${match_id}`);
//     const matchSnap = await matchRef.once("value");

//     if (!matchSnap.exists()) {
//       return res.status(404).json({ error: "Match not found" });
//     }

//     await matchRef.child("assigned_admin").set(match_admin_id);

//     res.json({ message: "Match admin assigned" });
//   }
// );

// ================================
// ASSIGN MATCH ADMIN (SUPER ADMIN)
// ================================
// app.post("/superadmin/assign-match-admin", async (req, res) => {
//   console.log("RAW BODY:", req.body);

//   const { match_id, admin_id: adminId, adminName } = req.body;

//   console.log("PARSED:", match_id, adminId, adminName);

//   if (!match_id || !adminId || !adminName) {
//     return res.status(400).json({
//       error: "Missing required fields",
//       received: req.body,
//     });
//   }

//   try {
//     const updates = {};

//     updates[`matches/${match_id}/assigned_admin`] = {
//       adminId,
//       adminName,
//       assignedAt: Date.now(),
//     };

//     updates[`admins/${adminId}/assigned_matches/${match_id}`] = true;

//     await db.ref().update(updates);

//     return res.json({
//       message: "Match admin assigned successfully",
//     });
//   } catch (error) {
//     console.error("FIREBASE ERROR:", error);
//     return res.status(500).json({ error: "Firebase update failed" });
//   }
// });

// app.get("/superadmin/match-admins", adminAuth, async (req, res) => {
//   try {
//     const collegeId = req.admin.college_id;

//     const snap = await db.ref(`admins`).once("value");

//     if (!snap.exists()) return res.json([]);

//     const admins = [];

//     snap.forEach(child => {
//       const admin = child.val();

//       // only match admins from same college
//       if (
//         admin.college_id === collegeId &&
//         admin.role === "match_admin"
//       ) {
//         admins.push({
//           adminId: child.key,
//           name: admin.name,
//           role: admin.role,
//         });
//       }
//     });

//     res.json(admins);
//   } catch (e) {
//     res.status(500).json({ error: "Failed to load admins" });
//   }
// });

app.get(
  "/superadmin/match-admins",
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const collegeId = req.user.collegeId;

      console.log("FETCHING MATCH ADMINS FOR COLLEGE:", collegeId, typeof collegeId);

      const snap = await db.ref("users").once("value");

      if (!snap.exists()) {
        return res.json([]);
      }

      const admins = [];

      snap.forEach((child) => {
        const user = child.val();

        console.log(
          "CHECKING USER:",
          user.name,
          "ROLE:", user.role,
          "COLLEGE:", user.collegeId,
          "APPROVAL:", user.approvalStatus
        );

        if (
          user.role === "match_admin" &&
          String(user.collegeId || "").toLowerCase() ===
              String(collegeId || "").toLowerCase() &&
          user.approvalStatus === "approved"
        ) {
          admins.push({
            adminId: child.key,
            name: user.name,
            role: user.role,
            email: user.email,
          });
        }
      });

      console.log("MATCH ADMINS FOUND:", admins.length);

      return res.json(admins);
    } catch (err) {
      console.error("FETCH MATCH ADMINS ERROR:", err);
      return res.status(500).json({ error: "Failed to load admins" });
    }
  }
);


// app.get("/admin/matches", adminAuth,requireSuperAdmin, async (req, res) => {
//   try {
//     const { college_id } = req.admin;

//     const tournamentsSnap = await db
//       .ref(`tournaments/${college_id}`)
//       .once("value");

//     if (!tournamentsSnap.exists()) {
//       return res.json([]);
//     }

//     const tournaments = tournamentsSnap.val();
//     const allMatches = [];

//     // 🔁 iterate tournaments
//     for (const tournamentId in tournaments) {
//       const tournament = tournaments[tournamentId];
//       if (!tournament.matches) continue;

//       for (const matchId in tournament.matches) {
//         allMatches.push({
//           matchId,
//           tournamentId,
//           ...tournament.matches[matchId],
//         });
//       }
//     }

//     return res.json(allMatches);
//   } catch (err) {
//     console.error("ADMIN MATCH AGG ERROR:", err);
//     return res.status(500).json({ error: "Failed to fetch matches" });
//   }
// });

app.get(
  "/admin/matches",
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const collegeId = req.user.collegeId;

      const tournamentsSnap = await db.ref(`tournaments/${collegeId}`).once("value");

      if (!tournamentsSnap.exists()) {
        return res.json([]);
      }

      const tournaments = tournamentsSnap.val();
      const allMatches = [];

      for (const tournamentId in tournaments) {
        const tournament = tournaments[tournamentId];

        if (!tournament.matches) continue;

        for (const matchId in tournament.matches) {
          allMatches.push({
            ...tournament.matches[matchId],
            matchId,
            tournamentId,
          });
        }
      }

      return res.json(allMatches);
    } catch (err) {
      console.error("ADMIN MATCH AGG ERROR:", err);
      return res.status(500).json({ error: "Failed to fetch matches" });
    }
  }
);





// app.get(
//   "/admin/my-matches",
//   adminAuth,
//   requireMatchAdmin,
//   async (req, res) => {
//     const college_id = req.admin.college_id;
//     const adminId = req.admin.admin_id;

//     const snapshot = await db.ref(`matches/${college_id}`).once("value");
//     const result = [];

//     snapshot.forEach((child) => {
//       const match = child.val();
//       if (match.assigned_admin === adminId) {
//         result.push(match);
//       }
//     });

//     res.json(result);
//   }
// );

app.get(
  "/admin/assigned-matches",
  authMiddleware,
  requireMatchAdmin,
  async (req, res) => {
    try {
      const adminId = req.user.uid;
      const collegeId = String(req.user.collegeId || "").trim().toLowerCase();

      console.log("FETCH ASSIGNED MATCHES FOR:", {
        adminId,
        collegeId,
        role: req.user.role,
      });

      const tournamentsSnap = await db.ref(`tournaments/${collegeId}`).once("value");

      if (!tournamentsSnap.exists()) {
        console.log("NO TOURNAMENTS FOUND FOR COLLEGE:", collegeId);
        return res.json([]);
      }

      const assignedMatches = [];
      const tournaments = tournamentsSnap.val();

      for (const tournamentId in tournaments) {
        const matches = tournaments[tournamentId].matches;
        if (!matches) continue;

        for (const matchId in matches) {
          const match = matches[matchId];

          console.log("CHECK MATCH:", {
            tournamentId,
            matchId,
            matchName: match.name,
            assignedAdminId: match.assigned_admin?.adminId,
            currentAdminId: adminId,
            status: match.status,
          });

          if (match.assigned_admin?.adminId === adminId) {
            assignedMatches.push({
              ...match,
              status: match.status || "upcoming",
              matchId,
              tournamentId,
              collegeId,
            });
          }
        }
      }

      console.log("ASSIGNED MATCHES FOUND:", assignedMatches.length);

      return res.json(assignedMatches);
    } catch (err) {
      console.error("ASSIGNED MATCHES ERROR:", err);
      return res.status(500).json({ error: "Failed to fetch matches" });
    }
  }
);

// app.get(
//   "/match-admin/my-matches",
//   adminAuth,
//   requireMatchAdmin,
//   async (req, res) => {
//     const admin_id = req.admin.admin_id;

//     const snapshot = await db
//       .ref(`admins/${admin_id}/assigned_matches`)
//       .once("value");

//     const matchIds = snapshot.val() ?? {};
//     const matches = [];

//     for (const matchId of Object.keys(matchIds)) {
//       const matchSnap = await db
//         .ref(`matches/${matchId}`)
//         .once("value");
//       matches.push(matchSnap.val());
//     }

//     res.json(matches);
//   }
// );

// ================================
// 🔹 ADMIN: GET ASSIGNED MATCHES
// ================================
// app.get("/admin/assigned-matches", adminAuth, async (req, res) => {
//   try {
//     const adminId = req.headers["x-admin-id"];
//     const collegeId = req.admin.college_id;

//     console.log("ADMIN:", adminId, "COLLEGE:", collegeId);


//     const tournamentsSnap = await db
//       .ref(`tournaments/${collegeId}`)
//       .once("value");

//     if (!tournamentsSnap.exists()) {
//       return res.json([]);
//     }

//     const assignedMatches = [];

//     const tournaments = tournamentsSnap.val();

//     for (const tournamentId in tournaments) {
//       const matches = tournaments[tournamentId].matches;
//       if (!matches) continue;

//       for (const matchId in matches) {
//         const match = matches[matchId];

//         if (match.assigned_admin?.adminId === adminId) {
//           assignedMatches.push({
//             ...match,
//             status: match.status || "upcoming",
//             matchId,
//             tournamentId,
//             collegeId,
//           });
//         }
//       }
//     }

//     return res.json(assignedMatches);
//   } catch (err) {
//     console.error(err);
//     return res.status(500).json({ error: "Failed to fetch matches" });
//   }
// });



// app.post("/admin/match/:matchId/start", adminAuth, async (req, res) => {
//   try {
//     const { matchId } = req.params;
//     const adminId = req.headers["x-admin-id"];
//     const collegeId = req.admin.college_id;

//     // 🔍 Find match inside all tournaments of this college
//     const tournamentsSnap = await db
//       .ref(`tournaments/${collegeId}`)
//       .once("value");

//     if (!tournamentsSnap.exists()) {
//       return res.status(404).json({ error: "No tournaments found" });
//     }

//     let matchRef = null;
//     let matchData = null;

//     tournamentsSnap.forEach((tournamentSnap) => {
//       const matchesSnap = tournamentSnap.child("matches");
//       matchesSnap.forEach((mSnap) => {
//         if (mSnap.key === matchId) {
//           matchRef = mSnap.ref;
//           matchData = mSnap.val();
//         }
//       });
//     });

//     if (!matchRef || !matchData) {
//       return res.status(404).json({ error: "Match not found" });
//     }

//     // 🔐 Authorization
//     if (matchData.assigned_admin?.adminId !== adminId) {
//       return res.status(403).json({ error: "Not assigned admin" });
//     }

//     // 🔁 State validation
//     if (matchData.status !== "upcoming") {
//       return res.status(400).json({
//         error: "Match cannot be started from current state",
//       });
//     }

//     // ✅ Update match
//     await matchRef.update({
//       status: "live",
//       startedAt: Date.now(),
//     });

//     return res.json({ message: "Match started successfully" });
//   } catch (err) {
//     console.error(err);
//     return res.status(500).json({ error: "Failed to start match" });
//   }
// });

app.post(
  "/admin/match/:matchId/start",
  authMiddleware,
  requireMatchAdmin,
  async (req, res) => {
    try {
      const { matchId } = req.params;
      const { tournamentId } = req.body;

      const adminId = req.user.uid;
      const collegeId = String(req.user.collegeId || "").trim().toLowerCase();

      console.log("START MATCH REQUEST:", {
        matchId,
        tournamentId,
        adminId,
        collegeId,
      });

      const tournamentsRef = db.ref(`tournaments/${collegeId}`);
      const tournamentsSnap = await tournamentsRef.once("value");

      if (!tournamentsSnap.exists()) {
        return res.status(404).json({ error: "No tournaments found" });
      }

      const matchRef = db.ref(
        `tournaments/${collegeId}/${tournamentId}/matches/${matchId}`
      );

      const matchSnap = await matchRef.once("value");

      if (!matchSnap.exists()) {
        return res.status(404).json({ error: "Match not found" });
      }

      const match = matchSnap.val();

      if (match.assigned_admin?.adminId !== adminId) {
        return res.status(403).json({ error: "Not assigned admin" });
      }

      if (match.status === "live") {
        return res.status(400).json({ error: "Match already live" });
      }

      if (match.status === "finished") {
        return res.status(400).json({ error: "Match already finished" });
      }

      await matchRef.update({
        status: "live",
        startedAt: Date.now(),
      });

      return res.json({
        message: "Match started successfully",
      });
    } catch (err) {
      console.error("START MATCH ERROR:", err);
      return res.status(500).json({ error: "Failed to start match" });
    }
  }
);


// app.post("/admin/match/:matchId/end", adminAuth, async (req, res) => {
//   try {
//     const { matchId } = req.params;
//     const adminId = req.headers["x-admin-id"];
//     const collegeId = req.admin.college_id;
//     const { tournamentId } = req.body;

//     const matchRef = db.ref(
//       `tournaments/${collegeId}/${tournamentId}/matches/${matchId}`
//     );

//     const snapshot = await matchRef.once("value");

//     if (!snapshot.exists()) {
//       return res.status(404).json({ error: "Match not found" });
//     }

//     const match = snapshot.val();

//     if (match.assigned_admin?.adminId !== adminId) {
//       return res.status(403).json({ error: "Not assigned admin" });
//     }

//     if (match.status !== "live") {
//       return res.status(400).json({
//         error: "Only live matches can be ended",
//       });
//     }

//     await matchRef.update({
//       status: "finished",
//       endedAt: Date.now(),
//     });

//     return res.json({ message: "Match ended successfully" });
//   } catch (err) {
//     console.error("END MATCH ERROR:", err);
//     return res.status(500).json({ error: "Failed to end match" });
//   }
// });

app.post(
  "/admin/match/:matchId/end",
  authMiddleware,
  requireMatchAdmin,
  async (req, res) => {
    try {
      const { matchId } = req.params;
      const adminId = req.user.uid;
      const collegeId = req.user.collegeId;
      const { tournamentId } = req.body;

      if (!tournamentId) {
        return res.status(400).json({ error: "tournamentId is required" });
      }

      const matchRef = db.ref(
        `tournaments/${collegeId}/${tournamentId}/matches/${matchId}`
      );

      const snapshot = await matchRef.once("value");

      if (!snapshot.exists()) {
        return res.status(404).json({ error: "Match not found" });
      }

      const match = snapshot.val();

      if (match.assigned_admin?.adminId !== adminId) {
        return res.status(403).json({ error: "Not assigned admin" });
      }

      if (match.status !== "live") {
        return res.status(400).json({
          error: "Only live matches can be ended",
        });
      }

      await matchRef.update({
        status: "finished",
        endedAt: Date.now(),
      });

      return res.json({ message: "Match ended successfully" });
    } catch (err) {
      console.error("END MATCH ERROR:", err);
      return res.status(500).json({ error: "Failed to end match" });
    }
  }
);






app.get("/", (req, res) => {
  res.send("PlayTalk backend is running 🚀");
});

// ==============================
// 🔐 AUTH ROUTES
// ==============================

// Register new user (User, Match Admin or Super Admin)
app.post("/auth/register", upload.single("idProof"), async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    // Support BOTH old frontend field (college) and future field (collegeId)
    const rawCollege = req.body.college || req.body.collegeId;

    const idProofPath = req.file ? req.file.path : null;

    console.log("REGISTER REQUEST BODY:", req.body);
    console.log("REGISTER FILE:", req.file ? req.file.path : "No file");

    // ===============================
    // VALIDATION
    // ===============================
    if (!name || !email || !password || !rawCollege || !role) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const normalizedName = String(name).trim();
    const normalizedEmail = String(email).trim().toLowerCase();
    const normalizedRole = String(role).trim().toLowerCase();
    const normalizedCollegeId = String(rawCollege).trim().toLowerCase();

    if (!["user", "match_admin", "super_admin"].includes(normalizedRole)) {
      return res.status(400).json({ error: "Invalid role selected" });
    }

    // Admins require ID proof
    if (normalizedRole !== "user" && !idProofPath) {
      return res.status(400).json({
        error: "ID proof photo is required for admins",
      });
    }

    // ===============================
    // CHECK IF EMAIL ALREADY EXISTS IN FIREBASE AUTH
    // (Firebase Auth itself will also protect against duplicates)
    // ===============================
    try {
      await auth.getUserByEmail(normalizedEmail);
      return res.status(400).json({ error: "Email already registered" });
    } catch (authErr) {
      // If user not found, Firebase throws auth/user-not-found → that's OK
      if (authErr.code !== "auth/user-not-found") {
        console.error("CHECK EMAIL ERROR:", authErr);
        return res.status(500).json({ error: "Failed to validate email" });
      }
    }

    // ===============================
    // CREATE FIREBASE AUTH USER
    // ===============================
    const userRecord = await auth.createUser({
      email: normalizedEmail,
      password: password,
      displayName: normalizedName,
    });

    const uid = userRecord.uid;

    // ===============================
    // DETERMINE APPROVAL STATUS
    // ===============================
    const approvalStatus =
        normalizedRole === "user" ? "approved" : "pending";

    // ===============================
    // SAVE USER PROFILE IN /users/{uid}
    // ===============================
    const userData = {
      uid,
      name: normalizedName,
      email: normalizedEmail,
      role: normalizedRole,
      collegeId: normalizedCollegeId,
      approvalStatus,
      idProofPath: idProofPath || null,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };

    await db.ref(`users/${uid}`).set(userData);

    console.log("REGISTERED USER SAVED TO /users:", userData);

    // ===============================
    // RESPONSE
    // ===============================
    return res.status(201).json({
      message:
          normalizedRole === "user"
              ? "Registration successful! You can now login."
              : "Registration submitted. Pending approval.",
      uid,
      role: normalizedRole,
      approvalStatus,
    });
  } catch (error) {
    console.error("REGISTRATION ERROR:", error);

    if (error.code === "auth/email-already-exists") {
      return res.status(400).json({ error: "Email already registered" });
    }

    return res.status(500).json({ error: "Registration failed" });
  }
});

// Login
app.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }

    // First check approved admins
    let adminSnapshot = await db.ref("admins").orderByChild("email").equalTo(email).once("value");
    
    let admin = null;
    let adminId = null;

    if (adminSnapshot.exists()) {
      adminSnapshot.forEach((child) => {
        const data = child.val();
        if (data.password === password) {
          admin = data;
          adminId = child.key;
        }
      });
    }

    if (admin) {
      // Check approval status
      if (admin.status === "pending") {
        return res.status(403).json({ error: "Your account is pending approval" });
      }
      if (admin.status === "rejected") {
        return res.status(403).json({ error: "Your account has been rejected" });
      }

      return res.json({
        message: "Login successful",
        adminId,
        name: admin.name,
        email: admin.email,
        role: admin.role,
        collegeId: admin.college_id,
      });
    }

    // Check pending admins
    const pendingSnapshot = await db.ref("pending_admins").orderByChild("email").equalTo(email).once("value");
    
    if (pendingSnapshot.exists()) {
      let pendingAdmin = null;
      pendingSnapshot.forEach((child) => {
        const data = child.val();
        if (data.password === password) {
          pendingAdmin = data;
        }
      });

      if (pendingAdmin) {
        return res.status(403).json({ 
          error: "Your account is pending approval. Please wait for verification.",
          pending: true 
        });
      }
    }

    return res.status(401).json({ error: "Invalid credentials" });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
});

// Developer: Get pending Super Admin requests
app.get("/auth/developer/super-admin-requests", async (req, res) => {
  try {
    const developerKey = req.headers["x-developer-key"];
    
    if (developerKey !== "dev_secret_key_2024") {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const snapshot = await db.ref("pending_admins")
      .orderByChild("role")
      .equalTo("super_admin")
      .once("value");

    const requests = [];
    if (snapshot.exists()) {
      snapshot.forEach((child) => {
        const data = child.val();
        if (data.status === "pending") {
          requests.push({
            id: child.key,
            name: data.name,
            email: data.email,
            college: data.college,
            role: data.role,
            idProofPath: data.idProofPath,
            createdAt: new Date(data.createdAt).toISOString(),
          });
        }
      });
    }

    res.json(requests);
  } catch (error) {
    console.error("Error fetching Super Admin requests:", error);
    res.status(500).json({ error: "Failed to fetch requests" });
  }
});

// Developer: Verify Super Admin
app.post("/auth/developer/verify-super-admin", async (req, res) => {
  try {
    const developerKey = req.headers["x-developer-key"];
    
    if (developerKey !== "dev_secret_key_2024") {
      return res.status(401).json({ error: "Unauthorized" });
    }

    const { adminId, action } = req.body;

    if (!adminId || !action) {
      return res.status(400).json({ error: "adminId and action required" });
    }

    // Get pending admin data
    const pendingRef = db.ref(`pending_admins/${adminId}`);
    const pendingSnapshot = await pendingRef.once("value");

    if (!pendingSnapshot.exists()) {
      return res.status(404).json({ error: "Pending admin not found" });
    }

    const pendingData = pendingSnapshot.val();

    if (action === "approve") {
      // Move to approved admins
      const approvedRef = db.ref("admins").push();
      const approvedId = approvedRef.key;

      await approvedRef.set({
        admin_id: approvedId,
        name: pendingData.name,
        email: pendingData.email,
        password: pendingData.password,
        college: pendingData.college,
        role: pendingData.role,
        college_id: pendingData.college, // Use college as college_id for now
        status: "approved",
        approvedAt: Date.now(),
        createdAt: pendingData.createdAt,
      });

      // Update pending status
      await pendingRef.update({ status: "approved", approvedAdminId: approvedId });

      return res.json({ message: "Super Admin approved successfully" });
    } else if (action === "reject") {
      await pendingRef.update({ status: "rejected" });
      return res.json({ message: "Super Admin rejected" });
    }

    return res.status(400).json({ error: "Invalid action" });
  } catch (error) {
    console.error("Verification error:", error);
    res.status(500).json({ error: "Verification failed" });
  }
});

// Super Admin: Get pending Match Admin requests
// app.get("/auth/super-admin/pending-match-admins", adminAuth, requireSuperAdmin, async (req, res) => {
//   try {
//     const collegeId = req.admin.college_id;

//     const snapshot = await db.ref("pending_admins")
//       .orderByChild("role")
//       .equalTo("match_admin")
//       .once("value");

//     const requests = [];
//     if (snapshot.exists()) {
//       snapshot.forEach((child) => {
//         const data = child.val();
//         if (data.status === "pending" && data.college === collegeId) {
//           requests.push({
//             id: child.key,
//             name: data.name,
//             email: data.email,
//             college: data.college,
//             role: data.role,
//             idProofPath: data.idProofPath,
//             createdAt: new Date(data.createdAt).toISOString(),
//           });
//         }
//       });
//     }

//     res.json(requests);
//   } catch (error) {
//     console.error("Error fetching Match Admin requests:", error);
//     res.status(500).json({ error: "Failed to fetch requests" });
//   }
// });

// Super Admin: Verify Match Admin
// app.post("/auth/super-admin/verify-match-admin", adminAuth, requireSuperAdmin, async (req, res) => {
//   try {
//     const { adminId, action } = req.body;
//     const collegeId = req.admin.college_id;

//     if (!adminId || !action) {
//       return res.status(400).json({ error: "adminId and action required" });
//     }

//     // Get pending admin data
//     const pendingRef = db.ref(`pending_admins/${adminId}`);
//     const pendingSnapshot = await pendingRef.once("value");

//     if (!pendingSnapshot.exists()) {
//       return res.status(404).json({ error: "Pending admin not found" });
//     }

//     const pendingData = pendingSnapshot.val();

//     // Verify college matches
//     if (pendingData.college !== collegeId) {
//       return res.status(403).json({ error: "College mismatch" });
//     }

//     if (action === "approve") {
//       // Move to approved admins
//       const approvedRef = db.ref("admins").push();
//       const approvedId = approvedRef.key;

//       await approvedRef.set({
//         admin_id: approvedId,
//         name: pendingData.name,
//         email: pendingData.email,
//         password: pendingData.password,
//         college: pendingData.college,
//         role: "match_admin",
//         college_id: collegeId,
//         status: "approved",
//         approvedAt: Date.now(),
//         createdAt: pendingData.createdAt,
//       });

//       // Update pending status
//       await pendingRef.update({ status: "approved", approvedAdminId: approvedId });

//       return res.json({ message: "Match Admin approved successfully" });
//     } else if (action === "reject") {
//       await pendingRef.update({ status: "rejected" });
//       return res.json({ message: "Match Admin rejected" });
//     }

//     return res.status(400).json({ error: "Invalid action" });
//   } catch (error) {
//     console.error("Verification error:", error);
//     res.status(500).json({ error: "Verification failed" });
//   }
// });

app.get(
  "/auth/super-admin/pending-match-admins",
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const collegeId = req.user.collegeId;

      const snapshot = await db.ref("users").once("value");

      const requests = [];

      if (snapshot.exists()) {
        snapshot.forEach((child) => {
          const user = child.val();

          if (
            user.role === "match_admin" &&
            user.approvalStatus === "pending" &&
            user.collegeId === collegeId
          ) {
            requests.push({
              uid: child.key,
              name: user.name,
              email: user.email,
              role: user.role,
              collegeId: user.collegeId,
              createdAt: user.createdAt ?? null,
              updatedAt: user.updatedAt ?? null,
            });
          }
        });
      }

      return res.json(requests);
    } catch (error) {
      console.error("FETCH PENDING MATCH ADMINS ERROR:", error);
      return res.status(500).json({ error: "Failed to fetch requests" });
    }
  }
);

app.post(
  "/auth/super-admin/verify-match-admin",
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const { uid, action } = req.body;
      const collegeId = req.user.collegeId;

      if (!uid || !action) {
        return res.status(400).json({ error: "uid and action are required" });
      }

      if (!["approve", "reject"].includes(action)) {
        return res.status(400).json({ error: "Invalid action" });
      }

      const userRef = db.ref(`users/${uid}`);
      const snapshot = await userRef.once("value");

      if (!snapshot.exists()) {
        return res.status(404).json({ error: "Match admin profile not found" });
      }

      const user = snapshot.val();

      if (user.role !== "match_admin") {
        return res.status(400).json({ error: "Selected user is not a match admin" });
      }

      if (user.collegeId !== collegeId) {
        return res.status(403).json({ error: "College mismatch" });
      }

      if (action === "approve") {
        await userRef.update({
          approvalStatus: "approved",
          updatedAt: Date.now(),
        });

        return res.json({ message: "Match Admin approved successfully" });
      }

      if (action === "reject") {
        await userRef.update({
          approvalStatus: "rejected",
          updatedAt: Date.now(),
        });

        return res.json({ message: "Match Admin rejected successfully" });
      }
    } catch (error) {
      console.error("VERIFY MATCH ADMIN ERROR:", error);
      return res.status(500).json({ error: "Verification failed" });
    }
  }
);


app.get(
  "/user/matches",
  authMiddleware,
  requireApprovedUser,
  async (req, res) => {
    try {
      const rawCollegeId = String(req.user.collegeId || "").trim();

      if (!rawCollegeId) {
        console.log("USER PROFILE MISSING collegeId:", req.user.uid);
        return res.status(400).json({ error: "User collegeId missing in profile" });
      }

      const normalizedCollegeId = rawCollegeId.toLowerCase();

      console.log("FETCH USER MATCHES FOR:", {
        uid: req.user.uid,
        role: req.user.role,
        rawCollegeId,
        normalizedCollegeId,
      });

      let tournamentsSnap = await db.ref(`tournaments/${normalizedCollegeId}`).once("value");
      let resolvedCollegeId = normalizedCollegeId;

      if (!tournamentsSnap.exists() && rawCollegeId !== normalizedCollegeId) {
        console.log("LOWERCASE PATH NOT FOUND, TRYING RAW PATH:", `tournaments/${rawCollegeId}`);
        tournamentsSnap = await db.ref(`tournaments/${rawCollegeId}`).once("value");
        resolvedCollegeId = rawCollegeId;
      }

      if (!tournamentsSnap.exists()) {
        console.log("NO TOURNAMENTS FOUND FOR USER COLLEGE:", resolvedCollegeId);
        return res.json([]);
      }

      const tournaments = tournamentsSnap.val();
      const allMatches = [];

      for (const tournamentId in tournaments) {
        const tournament = tournaments[tournamentId];
        const matches = tournament.matches || {};

        console.log(
          "TOURNAMENT:",
          tournamentId,
          "MATCH COUNT:",
          Object.keys(matches).length
        );

        for (const matchId in matches) {
          const match = matches[matchId];

          // ✅ DEFAULT FLAT SCORES
          let teamAScore = Number(match.teamAScore || 0);
          let teamBScore = Number(match.teamBScore || 0);

          // ✅ HANDLE NESTED SCORE STRUCTURE (BADMINTON / LIVE SCORING)
          if (match.score) {
            if (match.score.currentSet) {
              teamAScore = Number(match.score.currentSet.A || 0);
              teamBScore = Number(match.score.currentSet.B || 0);
            } else {
              teamAScore = Number(
                match.score.teamA ??
                match.score.teamAScore ??
                match.score.a ??
                match.score.scoreA ??
                teamAScore
              );

              teamBScore = Number(
                match.score.teamB ??
                match.score.teamBScore ??
                match.score.b ??
                match.score.scoreB ??
                teamBScore
              );
            }
          }
          console.log("USER MATCH SCORE DEBUG:", {
  matchId,
  name: match.name,
  rawScore: match.score,
  finalTeamAScore: teamAScore,
  finalTeamBScore: teamBScore,
});
          allMatches.push({
            ...match,
            matchId,
            tournamentId,
            tournamentName: tournament.name || "",
            collegeId: resolvedCollegeId,
            status: match.status || "upcoming",

            // ✅ SEND FLAT SCORES FOR FLUTTER UI
            teamAScore,
            teamBScore,

            // optional: keep raw score too (good for debugging / future use)
            score: match.score || { teamA: teamAScore, teamB: teamBScore },
          });
        }
      }

      console.log("TOTAL USER MATCHES RETURNED:", allMatches.length);

      return res.json(allMatches);
    } catch (err) {
      console.error("USER MATCHES ERROR:", err);
      return res.status(500).json({ error: "Failed to fetch matches" });
    }
  }
);



app.listen(3000, "0.0.0.0", () => {
  console.log("PlayTalk backend running on port 3000 🚀");
});

