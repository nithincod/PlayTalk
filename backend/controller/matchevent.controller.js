import { db } from "../config/firebase.js";
import { applyRules } from "../rules/index.js";
import { generateCommentary } from "../services/commentary/index.js"; // ✅ NEW

// ==========================================================
// HELPERS
// ==========================================================

function buildMatchName(teamA, teamB) {
  const a = teamA && teamA !== "TBD" ? teamA : "TBD";
  const b = teamB && teamB !== "TBD" ? teamB : "TBD";
  return `${a} vs ${b}`;
}

async function propagateBracketWinner({
  tournamentId,
  collegeId,
  currentMatchId,
  currentMatch,
  winner,
}) {
  const tournamentPath = `tournaments/${collegeId}/${tournamentId}`;
  const tournamentMatchesPath = `tournaments/${collegeId}/${tournamentId}/matches`;

  // ========================================================
  // 1) SAFETY CHECKS
  // ========================================================
  if (currentMatch.isBracketMatch !== true) {
    return {
      propagated: false,
      reason: "not_bracket_match",
    };
  }

  if (!winner) {
    return {
      propagated: false,
      reason: "winner_missing",
    };
  }

  const nextMatchId = currentMatch.nextMatchId || null;

  // ========================================================
  // 2) FINAL MATCH => DECLARE CHAMPION
  // ========================================================
  if (!nextMatchId) {
    await db.ref(tournamentPath).update({
      champion: winner,
      bracketCompleted: true,
      completedAt: Date.now(),
    });

    console.log("👑 Champion declared:", winner);

    return {
      propagated: false,
      finalMatch: true,
      champion: winner,
    };
  }

  // ========================================================
  // 3) FETCH NEXT MATCH FROM GLOBAL ROOT
  // ========================================================
  const nextMatchSnap = await db.ref(`matches/${nextMatchId}`).once("value");

  if (!nextMatchSnap.exists()) {
    console.log("❌ Next bracket match not found in global root:", nextMatchId);

    return {
      propagated: false,
      reason: "next_match_not_found",
      nextMatchId,
    };
  }

  const nextMatch = nextMatchSnap.val();

  let updatedTeamA = nextMatch.teamA || "TBD";
  let updatedTeamB = nextMatch.teamB || "TBD";

  // ========================================================
  // 4) PREVENT DUPLICATE PROPAGATION
  // ========================================================
  if (updatedTeamA === winner || updatedTeamB === winner) {
    console.log("⚠️ Winner already propagated:", winner);

    return {
      propagated: false,
      reason: "already_propagated",
      nextMatchId,
      nextMatch: {
        teamA: updatedTeamA,
        teamB: updatedTeamB,
        name: nextMatch.name,
      },
    };
  }

  // ========================================================
  // 5) FILL FIRST AVAILABLE SLOT
  // ========================================================
  if (!updatedTeamA || updatedTeamA === "TBD") {
    updatedTeamA = winner;
  } else if (!updatedTeamB || updatedTeamB === "TBD") {
    updatedTeamB = winner;
  } else {
    console.log("❌ Next bracket match already full:", nextMatchId);

    return {
      propagated: false,
      reason: "next_match_full",
      nextMatchId,
      nextMatch: {
        teamA: updatedTeamA,
        teamB: updatedTeamB,
      },
    };
  }

  const updatedName = buildMatchName(updatedTeamA, updatedTeamB);

  const nextMatchPayload = {
    teamA: updatedTeamA,
    teamB: updatedTeamB,
    name: updatedName,
  };

  // ========================================================
  // 6) UPDATE NEXT MATCH IN GLOBAL ROOT
  // ========================================================
  await db.ref(`matches/${nextMatchId}`).update(nextMatchPayload);

  // ========================================================
  // 7) UPDATE NEXT MATCH IN TOURNAMENT MIRROR (IF EXISTS)
  // ========================================================
  const nextTournamentMatchRef = db.ref(`${tournamentMatchesPath}/${nextMatchId}`);
  const nextTournamentMatchSnap = await nextTournamentMatchRef.once("value");

  if (nextTournamentMatchSnap.exists()) {
    await nextTournamentMatchRef.update(nextMatchPayload);
  }

  console.log("✅ Winner propagated to next bracket match:", winner, "=>", nextMatchId);

  return {
    propagated: true,
    nextMatchId,
    nextMatch: {
      teamA: updatedTeamA,
      teamB: updatedTeamB,
      name: updatedName,
    },
  };
}

// ==========================================================
// MAIN CONTROLLER
// ==========================================================

export async function submitMatchEvent(req, res) {
  try {
    const { tournamentId, matchId } = req.params;
    const adminId = req.user.uid;
    const collegeId = String(req.user.collegeId || "").trim().toLowerCase();
    const { type, team, value, meta } = req.body;

    if (!type || !team) {
      return res.status(400).json({ error: "type and team are required" });
    }

    const tournamentMatchPath = `tournaments/${collegeId}/${tournamentId}/matches/${matchId}`;
    const tournamentMatchRef = db.ref(tournamentMatchPath);

    // ======================================================
    // 1) FETCH TOURNAMENT MATCH NODE (for auth/events/live status)
    // ======================================================
    const tournamentSnapshot = await tournamentMatchRef.once("value");

    if (!tournamentSnapshot.exists()) {
      return res.status(404).json({ error: "Match not found in tournament node" });
    }

    const tournamentMatch = tournamentSnapshot.val();

    // ======================================================
    // 2) FETCH GLOBAL MATCH NODE (source of truth for bracket fields)
    // ======================================================
    const globalMatchRef = db.ref(`matches/${matchId}`);
    const globalSnapshot = await globalMatchRef.once("value");

    let globalMatch = null;
    if (globalSnapshot.exists()) {
      globalMatch = globalSnapshot.val();
    }

    // ======================================================
    // 3) AUTH CHECK
    // ======================================================
    if (tournamentMatch.assigned_admin?.adminId !== adminId) {
      return res.status(403).json({ error: "Not assigned admin" });
    }

    // ======================================================
    // 4) MATCH MUST BE LIVE
    // ======================================================
    if (tournamentMatch.status !== "live") {
      return res.status(400).json({
        error: "Events can only be added when match is live",
      });
    }

    // ======================================================
    // 5) SAVE EVENT IN TOURNAMENT MATCH NODE
    // ======================================================
    const eventRef = tournamentMatchRef.child("events").push();

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

    // OPTIONAL: mirror event to global match node too
    if (globalMatchRef) {
      const globalEventRef = globalMatchRef.child("events").child(eventRef.key);
      await globalEventRef.set(event);
    }

    // ======================================================
    // 6) APPLY RULES
    // IMPORTANT:
    // Use tournamentMatch because it contains live event context
    // ======================================================
    console.log("MATCH SPORT FROM DB:", tournamentMatch.sport);

    const updatedState = applyRules(tournamentMatch.sport, tournamentMatch, event);

    // ======================================================
    // 7) UPDATE MATCH STATE IN TOURNAMENT NODE + GLOBAL NODE
    // ======================================================
    if (updatedState && typeof updatedState === "object") {
      await tournamentMatchRef.update(updatedState);

      if (globalSnapshot.exists()) {
        await globalMatchRef.update(updatedState);
      }
    }

    // ======================================================
    // 8) REFETCH UPDATED MATCHES AFTER RULES APPLIED
    // ======================================================
    const updatedTournamentSnap = await tournamentMatchRef.once("value");
    const updatedTournamentMatch = updatedTournamentSnap.val();

    let updatedGlobalMatch = updatedTournamentMatch;

    if (globalSnapshot.exists()) {
      const updatedGlobalSnap = await globalMatchRef.once("value");
      if (updatedGlobalSnap.exists()) {
        updatedGlobalMatch = updatedGlobalSnap.val();
      }
    }

    // ======================================================
// 8.5) GENERATE + SAVE AI COMMENTARY  ✅ FIXED
// Save commentary INSIDE the event node, not match-level root
// ======================================================
let savedCommentary = null;

if (updatedState && typeof updatedState === "object") {
  const commentary = generateCommentary({
    sport: tournamentMatch.sport,
    matchBefore: tournamentMatch,
    event,
    updatedState,
  });

  if (commentary?.text) {
    savedCommentary = {
      commentaryId: db.ref().push().key,
      eventId: event.eventId,
      type: "ai_commentary",
      category: commentary.category || "point",
      important: commentary.important === true,
      text: commentary.text,
      createdAt: Date.now(),
      scoreSnapshot: updatedState.score || null,
    };

    // ✅ Save commentary INSIDE tournament event node
    await tournamentMatchRef
      .child("events")
      .child(eventRef.key)
      .child("commentary")
      .set(savedCommentary);

    // ✅ Mirror commentary INSIDE global event node too
    if (globalSnapshot.exists()) {
      await globalMatchRef
        .child("events")
        .child(eventRef.key)
        .child("commentary")
        .set(savedCommentary);
    }

    // ✅ Attach to returned event object too (nice for immediate API response)
    event.commentary = savedCommentary;

    console.log("🎙️ Commentary saved inside event:", savedCommentary.text);
  }
}

    // ======================================================
    // 9) BRACKET WINNER PROPAGATION
    // Trigger ONLY when match just became finished with winner
    // ======================================================
    let bracketResult = null;

    const becameFinishedNow =
      tournamentMatch.status !== "finished" &&
      updatedTournamentMatch.status === "finished";

    const winner =
      updatedTournamentMatch.winner ||
      updatedGlobalMatch?.winner ||
      updatedState?.winner ||
      null;

    if (becameFinishedNow && winner) {
      console.log("🏁 Match finished now, checking bracket propagation...");
      console.log("🏁 Winner =", winner);

      bracketResult = await propagateBracketWinner({
        tournamentId,
        collegeId,
        currentMatchId: matchId,
        currentMatch: updatedGlobalMatch,
        winner,
      });
    }

    // ======================================================
    // 10) RESPONSE
    // ======================================================
    return res.json({
      message: "Event submitted successfully",
      event,
      updatedState: updatedState || {},
      commentary: savedCommentary, // ✅ NEW
      bracketResult,
    });
  } catch (err) {
    console.error("SUBMIT EVENT ERROR:", err);
    return res.status(500).json({ error: "Failed to submit event" });
  }
}