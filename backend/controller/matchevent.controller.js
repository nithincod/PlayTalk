import { db } from "../config/firebase.js";
import { applyRules } from "/Users/sagilinithin/Desktop/PlayTalk/backend/rules/index.js";
export async function submitMatchEvent(req, res) {
  try {
    const { tournamentId, matchId } = req.params;
    const adminId = req.headers["x-admin-id"];
    const { type, team, value, meta } = req.body;

    const collegeId = req.admin.college_id;

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

    const eventRef = matchRef.child("events").push();

    const event = {
      eventId: eventRef.key,
      type,
      team,
      value,
      meta: meta || {},
      timestamp: Date.now(),
      byAdmin: adminId,
    };

    await eventRef.set(event);
    console.log("MATCH SPORT FROM DB:", match.sport);

    const updatedState = applyRules(match.sport, match, event);
    await matchRef.update(updatedState);

    return res.json({ message: "Event submitted successfully" });
  } catch (err) {
    console.error("SUBMIT EVENT ERROR:", err);
    return res.status(500).json({ error: "Failed to submit event" });
  }
}
