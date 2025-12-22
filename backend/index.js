import express from "express";
import cors from "cors";
import axios from "axios";
import admin from "firebase-admin";
import fs from "fs";
import dotenv from "dotenv";

const app = express();
app.use(cors());
app.use(express.json());
dotenv.config();

const serviceAccount = JSON.parse(
  fs.readFileSync("./firebase-key.json", "utf8")
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://playtalk-5df80-default-rtdb.firebaseio.com"
});

const db = admin.database();

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






app.get("/", (req, res) => {
  res.send("PlayTalk backend is running 🚀");
});

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
