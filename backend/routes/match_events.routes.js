import express from "express";
import { db } from "../config/firebase.js";
import { submitMatchEvent } from "../controller/matchevent.controller.js";

const router = express.Router();

async function adminAuth(req, res, next) {
  const adminId = req.headers["x-admin-id"];

  if (!adminId) {
    return res.status(401).json({ error: "Admin ID missing" });
  }

  const snapshot = await db.ref(`admins/${adminId}`).once("value");

  if (!snapshot.exists()) {
    return res.status(401).json({ error: "Invalid admin ID" });
  }

  req.admin = snapshot.val();
  next();
}

router.post(
  "/admin/tournament/:tournamentId/match/:matchId/event",
  adminAuth,
  submitMatchEvent
);

export default router;
