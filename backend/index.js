import express from "express";
import cors from "cors";
import axios from "axios";
import dotenv from "dotenv";

import "./config/firebase.js";

import { db } from "./config/firebase.js";

import matcheventsRouter from "./routes/match_events.routes.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
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

function requireSuperAdmin(req, res, next) {
  if (req.admin.role !== "super_admin") {
    return res.status(403).json({ error: "Super admin access required" });
  }
  next();
}

function requireMatchAdmin(req, res, next) {
  if (req.admin.role !== "match_admin") {
    return res.status(403).json({ error: "Match admin access required" });
  }
  next();
}



app.post("/system/create-college", async (req, res) => {
  const { name, code } = req.body;

  if (!(await collegeExists(college_id))) {
  return res.status(400).json({ error: "College does not exist" });
  }


  if (!name || !code) {
    return res.status(400).json({ error: "Invalid college data" });
  }

  const collegeRef = db.ref("colleges").push();
  const collegeId = collegeRef.key;

  await collegeRef.set({
    college_id: collegeId,
    name,
    code,
    created_at: Date.now()
  });

  res.json({
    message: "College created",
    college_id: collegeId
  });
});

app.post("/system/create-admin", async (req, res) => {
  const { name, college_id } = req.body;

  if (!(await collegeExists(college_id))) {
  return res.status(400).json({ error: "College does not exist" });
}


  if (!name || !college_id) {
    return res.status(400).json({ error: "Invalid admin data" });
  }

  // 1️⃣ Check if super admin already exists for this college
  const adminsSnapshot = await db.ref("admins").once("value");
  let superAdminExists = false;

  adminsSnapshot.forEach((child) => {
    const admin = child.val();
    if (
      admin.college_id === college_id &&
      admin.role === "super_admin"
    ) {
      superAdminExists = true;
    }
  });

  // 2️⃣ Decide role
  const role = superAdminExists ? "match_admin" : "super_admin";

  // 3️⃣ Create admin
  const adminRef = db.ref("admins").push();
  const adminId = adminRef.key;

  await adminRef.set({
    admin_id: adminId,
    name,
    role,
    college_id,
    created_at: Date.now()
  });

  res.json({
    message: "Admin created",
    admin_id: adminId,
    assigned_role: role
  });
});

app.post("/system/create-user", async (req, res) => {
  const { name, college_id } = req.body;

  const userRef = db.ref("users").push();
  const userId = userRef.key;

  if (!(await collegeExists(college_id))) {
  return res.status(400).json({ error: "College does not exist" });
}


  await userRef.set({
    user_id: userId,
    name,
    role: "user",
    college_id,
    created_at: Date.now()
  });

  res.json({
    message: "User created",
    user_id: userId
  });
});

app.post("/system/create-team", async (req, res) => {
  const { name, college_id, members } = req.body;

  if (!name || !college_id) {
    return res.status(400).json({ error: "Invalid team data" });
  }

  if (!(await collegeExists(college_id))) {
  return res.status(400).json({ error: "College does not exist" });
}

  const teamRef = db.ref("teams").push();
  const teamId = teamRef.key;

  await teamRef.set({
    team_id: teamId,
    name,
    college_id,
    members: members || [],
    created_at: Date.now()
  });

  res.json({
    message: "Team created",
    team_id: teamId
  });
});

app.post("/system/create-match", async (req, res) => {
  const { college_id, sport, participant_type, participantA, participantB } =
    req.body;

    if (!(await collegeExists(college_id))) {
  return res.status(400).json({ error: "College does not exist" });
}
  const ref = db.ref(`matches/${college_id}`).push();
  await ref.set({
    match_id: ref.key,
    sport,
    participant_type,
    participantA,
    participantB,
    status: "upcoming",
    created_at: Date.now()
  });

  res.json({ message: "Match created", match_id: ref.key });
});



app.get(
  "/admin/tournament/:tournamentId/matches",
  adminAuth,
  async (req, res) => {
    const { tournamentId } = req.params;
    const { college_id } = req.admin;

    const snap = await db
      .ref(`tournaments/${college_id}/${tournamentId}/matches`)
      .once("value");

    if (!snap.exists()) return res.json([]);

    const matches = Object.values(snap.val());
    res.json(matches);
  }
);


app.post(
  "/admin/tournament/:tournamentId/create-match",
  adminAuth,
  async (req, res) => {
    const { tournamentId } = req.params;
    const { name, teamA, teamB, court, matchType, sport } = req.body;

    if (!name || !teamA || !teamB) {
      return res.status(400).json({ error: "Missing fields" });
    }

    const { college_id } = req.admin;

    const ref = db
      .ref(`tournaments/${college_id}/${tournamentId}/matches`)
      .push();

    const match = {
      matchId: ref.key,
      name,
      teamA,
      teamB,
      court,
      matchType,
      sport,
      status: "upcoming",
      startedAt: null,
      endedAt: null,
      createdAt: Date.now(),
    };

    await ref.set(match);

    res.json(match);
  }
);

app.post(
  "/admin/tournament/:tournamentId/match/:matchId/assign-admin",
  adminAuth,
  async (req, res) => {
    const { tournamentId, matchId } = req.params;
    const { adminId, adminName } = req.body;
    const { college_id } = req.admin;

    if (!adminId || !adminName) {
      return res.status(400).json({ error: "Missing admin data" });
    }

    const assignPath = `tournaments/${college_id}/${tournamentId}/matches/${matchId}/assigned_admin`;

    console.log("WRITING TO:", assignPath);

    await db.ref(assignPath).set({
      adminId,
      adminName,
      assignedAt: Date.now(),
    });

    return res.json({
      message: "Admin assigned successfully",
      path: assignPath,
    });
  }
);



app.post("/system/create-tournament", async (req, res) => {
  const { name, sport, college_id, mode } = req.body;

  const ref = db.ref(`tournaments/${college_id}`).push();

  if (!(await collegeExists(college_id))) {
  return res.status(400).json({ error: "College does not exist" });
  }
  await ref.set({
    tournament_id: ref.key,
    name,
    sport,
    mode, // manual | automatic
    created_at: Date.now()
  });

  res.json({ message: "Tournament created", tournament_id: ref.key });
});

app.post(
  "/admin/create-tournament",
  adminAuth,
  requireSuperAdmin,
  async (req, res) => {
    const { name, sport, mode } = req.body;
    const college_id = req.admin.college_id;

    if (!name || !sport || !mode) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const ref = db.ref(`tournaments/${college_id}`).push();

    const tournament = {
      tournament_id: ref.key,
      name,
      sport,
      mode,
      created_at: Date.now(),
    };

    await ref.set(tournament);

    res.json({
      message: "Tournament created",
      tournament,
    });
  }
);

app.get(
  "/admin/tournaments",
  adminAuth,
  requireSuperAdmin,
  async (req, res) => {
    const college_id = req.admin.college_id;

    const snapshot = await db
      .ref(`tournaments/${college_id}`)
      .once("value");

    const tournaments = [];

    snapshot.forEach((child) => {
      tournaments.push(child.val());
    });

    res.json(tournaments);
  }
);



app.post(
  "/admin/assign-match",
  adminAuth,
  requireSuperAdmin,
  async (req, res) => {
    const { match_id, match_admin_id } = req.body;
    const college_id = req.admin.college_id;

    const matchRef = db.ref(`matches/${college_id}/${match_id}`);
    const matchSnap = await matchRef.once("value");

    if (!matchSnap.exists()) {
      return res.status(404).json({ error: "Match not found" });
    }

    await matchRef.child("assigned_admin").set(match_admin_id);

    res.json({ message: "Match admin assigned" });
  }
);

// ================================
// ASSIGN MATCH ADMIN (SUPER ADMIN)
// ================================
app.post("/superadmin/assign-match-admin", async (req, res) => {
  console.log("RAW BODY:", req.body);

  const { match_id, admin_id: adminId, adminName } = req.body;

  console.log("PARSED:", match_id, adminId, adminName);

  if (!match_id || !adminId || !adminName) {
    return res.status(400).json({
      error: "Missing required fields",
      received: req.body,
    });
  }

  try {
    const updates = {};

    updates[`matches/${match_id}/assigned_admin`] = {
      adminId,
      adminName,
      assignedAt: Date.now(),
    };

    updates[`admins/${adminId}/assigned_matches/${match_id}`] = true;

    await db.ref().update(updates);

    return res.json({
      message: "Match admin assigned successfully",
    });
  } catch (error) {
    console.error("FIREBASE ERROR:", error);
    return res.status(500).json({ error: "Firebase update failed" });
  }
});




app.get(
  "/admin/my-matches",
  adminAuth,
  requireMatchAdmin,
  async (req, res) => {
    const college_id = req.admin.college_id;
    const adminId = req.admin.admin_id;

    const snapshot = await db.ref(`matches/${college_id}`).once("value");
    const result = [];

    snapshot.forEach((child) => {
      const match = child.val();
      if (match.assigned_admin === adminId) {
        result.push(match);
      }
    });

    res.json(result);
  }
);

app.get(
  "/match-admin/my-matches",
  adminAuth,
  requireMatchAdmin,
  async (req, res) => {
    const admin_id = req.admin.admin_id;

    const snapshot = await db
      .ref(`admins/${admin_id}/assigned_matches`)
      .once("value");

    const matchIds = snapshot.val() ?? {};
    const matches = [];

    for (const matchId of Object.keys(matchIds)) {
      const matchSnap = await db
        .ref(`matches/${matchId}`)
        .once("value");
      matches.push(matchSnap.val());
    }

    res.json(matches);
  }
);

// ================================
// 🔹 ADMIN: GET ASSIGNED MATCHES
// ================================
app.get("/admin/assigned-matches", adminAuth, async (req, res) => {
  try {
    const adminId = req.headers["x-admin-id"];
    const collegeId = req.admin.college_id;

    const tournamentsSnap = await db
      .ref(`tournaments/${collegeId}`)
      .once("value");

    if (!tournamentsSnap.exists()) {
      return res.json([]);
    }

    const assignedMatches = [];

    const tournaments = tournamentsSnap.val();

    for (const tournamentId in tournaments) {
      const matches = tournaments[tournamentId].matches;
      if (!matches) continue;

      for (const matchId in matches) {
        const match = matches[matchId];

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

    return res.json(assignedMatches);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Failed to fetch matches" });
  }
});



app.post("/admin/match/:matchId/start", adminAuth, async (req, res) => {
  try {
    const { matchId } = req.params;
    const adminId = req.headers["x-admin-id"];
    const collegeId = req.admin.college_id;

    // 🔍 Find match inside all tournaments of this college
    const tournamentsSnap = await db
      .ref(`tournaments/${collegeId}`)
      .once("value");

    if (!tournamentsSnap.exists()) {
      return res.status(404).json({ error: "No tournaments found" });
    }

    let matchRef = null;
    let matchData = null;

    tournamentsSnap.forEach((tournamentSnap) => {
      const matchesSnap = tournamentSnap.child("matches");
      matchesSnap.forEach((mSnap) => {
        if (mSnap.key === matchId) {
          matchRef = mSnap.ref;
          matchData = mSnap.val();
        }
      });
    });

    if (!matchRef || !matchData) {
      return res.status(404).json({ error: "Match not found" });
    }

    // 🔐 Authorization
    if (matchData.assigned_admin?.adminId !== adminId) {
      return res.status(403).json({ error: "Not assigned admin" });
    }

    // 🔁 State validation
    if (matchData.status !== "upcoming") {
      return res.status(400).json({
        error: "Match cannot be started from current state",
      });
    }

    // ✅ Update match
    await matchRef.update({
      status: "live",
      startedAt: Date.now(),
    });

    return res.json({ message: "Match started successfully" });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Failed to start match" });
  }
});


app.post("/admin/match/:matchId/end", adminAuth, async (req, res) => {
  try {
    const { matchId } = req.params;
    const adminId = req.headers["x-admin-id"];
    const collegeId = req.admin.college_id;
    const { tournamentId } = req.body;

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
});






app.get("/", (req, res) => {
  res.send("PlayTalk backend is running 🚀");
});

const PORT = 3000;

app.listen(3000, "0.0.0.0", () => {
  console.log("PlayTalk backend running on port 3000 🚀");
});

