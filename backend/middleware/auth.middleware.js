import { auth, db } from "../config/firebase.js";

export async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ error: "Missing auth token" });
    }

    const token = authHeader.split(" ")[1];

    const decoded = await auth.verifyIdToken(token);
    const uid = decoded.uid;

    const snapshot = await db.ref(`users/${uid}`).once("value");

    if (!snapshot.exists()) {
      return res.status(401).json({ error: "User profile not found" });
    }

    const userProfile = snapshot.val();

    req.user = {
      uid,
      ...userProfile,
      collegeid: String(userProfile.collegeId || "").trim().toLowerCase(),
    };

    next();
  } catch (err) {
    console.error("AUTH MIDDLEWARE ERROR:", err);
    return res.status(401).json({ error: "Invalid auth token" });
  }
}