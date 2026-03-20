import { db } from "../config/firebase.js";
import { applyRules } from "../rules/index.js";

export async function submitMatchEvent(req, res) {
  try {
    const { tournamentId, matchId } = req.params;
    const adminId = req.user.uid;
    const collegeId = String(req.user.collegeId || "").trim().toLowerCase();
    const { type, team, value, meta } = req.body;

    if (!type || !team) {
      return res.status(400).json({ error: "type and team are required" });
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
      return res.status(400).json({ error: "Events can only be added when match is live" });
    }

    const eventRef = matchRef.child("events").push();

    const event = {
      eventId: eventRef.key,
      type,
      team,
      value: value ?? null,
      meta: meta || {},
      timestamp: Date.now(),
      byAdmin: adminId,
    };

    await eventRef.set(event);

    console.log("MATCH SPORT FROM DB:", match.sport);

    const updatedState = applyRules(match.sport, match, event);

    if (updatedState && typeof updatedState === "object") {
      await matchRef.update(updatedState);
    }

    return res.json({
      message: "Event submitted successfully",
      event,
      updatedState: updatedState || {},
    });
  } catch (err) {
    console.error("SUBMIT EVENT ERROR:", err);
    return res.status(500).json({ error: "Failed to submit event" });
  }
}