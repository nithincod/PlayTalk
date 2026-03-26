import express from "express";
import { db } from "../config/firebase.js";
import { authMiddleware } from "../middleware/auth.middleware.js";

const router = express.Router();

// ==========================================================
// HELPERS
// ==========================================================

function shuffleArray(arr) {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function nextPowerOf2(n) {
  let p = 1;
  while (p < n) p *= 2;
  return p;
}

function getRoundName(matchCount) {
  if (matchCount === 1) return "Final";
  if (matchCount === 2) return "Semi Final";
  if (matchCount === 4) return "Quarter Final";
  if (matchCount === 8) return "Round of 16";
  return `Round of ${matchCount * 2}`;
}

// ==========================================================
// POST /superadmin/tournament/:tournamentId/generate-bracket
// ==========================================================
router.post(
  "/superadmin/tournament/:tournamentId/generate-bracket",
  authMiddleware,
  async (req, res) => {
    try {
      const { tournamentId } = req.params;
      const collegeId = req.user?.collegeId;

      if (!collegeId) {
        return res.status(400).json({
          message: "collegeId missing in auth token",
        });
      }

      const tournamentPath = `tournaments/${collegeId}/${tournamentId}`;
      const teamsPath = `tournaments/${collegeId}/${tournamentId}/teams`;
      const tournamentMatchesPath = `tournaments/${collegeId}/${tournamentId}/matches`;

      console.log("🔥 generate-bracket tournamentId =", tournamentId);
      console.log("🔥 generate-bracket collegeId =", collegeId);
      console.log("🔥 tournamentPath =", tournamentPath);
      console.log("🔥 teamsPath =", teamsPath);

      // ======================================================
      // 1) FETCH TOURNAMENT
      // ======================================================
      const tournamentSnap = await db.ref(tournamentPath).once("value");

      if (!tournamentSnap.exists()) {
        return res.status(404).json({
          message: "Tournament not found",
          checkedPath: tournamentPath,
          tournamentId,
          collegeId,
        });
      }

      const tournament = tournamentSnap.val();

      // ======================================================
      // 2) FETCH TEAMS FROM TOURNAMENT NODE
      // ======================================================
      const teamsSnap = await db.ref(teamsPath).once("value");

      if (!teamsSnap.exists()) {
        return res.status(400).json({
          message: "No teams found for this tournament",
          checkedPath: teamsPath,
        });
      }

      const teamsObj = teamsSnap.val();

      let teams = Object.keys(teamsObj).map((key) => ({
        teamId: key,
        ...teamsObj[key],
      }));

      if (teams.length < 2) {
        return res.status(400).json({
          message: "At least 2 teams required for bracket generation",
          teamCount: teams.length,
        });
      }

      // ======================================================
      // 3) PREVENT DUPLICATE BRACKET GENERATION
      // Check global matches root
      // ======================================================
      const existingMatchesSnap = await db
        .ref("matches")
        .orderByChild("tournamentId")
        .equalTo(tournamentId)
        .once("value");

      let existingBracket = false;

      if (existingMatchesSnap.exists()) {
        const existingMatches = existingMatchesSnap.val();

        for (const key of Object.keys(existingMatches)) {
          if (existingMatches[key].isBracketMatch === true) {
            existingBracket = true;
            break;
          }
        }
      }

      if (existingBracket) {
        return res.status(400).json({
          message: "Bracket already generated for this tournament",
        });
      }

      // ======================================================
      // 4) SHUFFLE + BYE FILL
      // ======================================================
      teams = shuffleArray(teams);

      const originalCount = teams.length;
      const bracketSize = nextPowerOf2(originalCount);
      const byeCount = bracketSize - originalCount;

      for (let i = 0; i < byeCount; i++) {
        teams.push({
          teamId: `BYE_${i + 1}`,
          name: "BYE",
          sport: tournament.sport || teams[0]?.sport || "",
          players: [],
          captain: "",
          collegeId,
          isBye: true,
        });
      }

      const createdMatches = [];

      // ======================================================
      // 5) CREATE FIRST ROUND
      // ======================================================
      let roundIndex = 1;
      let previousRoundMatches = [];

      const firstRoundMatchCount = teams.length / 2;
      const firstRoundName = getRoundName(firstRoundMatchCount);

      for (let i = 0; i < teams.length; i += 2) {
        const teamA = teams[i];
        const teamB = teams[i + 1];

        const matchRef = db.ref("matches").push();

        let status = "upcoming";
        let winner = null;

        // Auto-finish if BYE
        if (teamA.name === "BYE" && teamB.name !== "BYE") {
          status = "finished";
          winner = teamB.name;
        } else if (teamB.name === "BYE" && teamA.name !== "BYE") {
          status = "finished";
          winner = teamA.name;
        }

        const matchData = {
          matchId: matchRef.key,
          tournamentId,
          collegeId,
          name: `${teamA.name} vs ${teamB.name}`,
          teamA: teamA.name,
          teamB: teamB.name,
          court: "TBD",
          matchType: "knockout",
          sport: (tournament.sport || teams[0]?.sport || "").toLowerCase(),
          status,
          assignAdmin: false,
          assigned_admin: null,
          startedAt: null,
          endedAt: null,
          createdAt: Date.now(),

          // Bracket fields
          isBracketMatch: true,
          round: firstRoundName,
          roundIndex,
          bracketOrder: previousRoundMatches.length + 1,
          nextMatchId: null,
          winner,
        };

        // Save full match in global matches root
        await matchRef.set(matchData);

        // Save lightweight reference inside tournament node
        await db.ref(`${tournamentMatchesPath}/${matchRef.key}`).set({
  matchId: matchRef.key,
  tournamentId,
  collegeId,
  name: matchData.name,
  teamA: matchData.teamA,
  teamB: matchData.teamB,
  round: matchData.round,
  roundIndex: matchData.roundIndex,
  bracketOrder: matchData.bracketOrder,
  status: matchData.status,
  isBracketMatch: true,
  createdAt: matchData.createdAt,
  sport: matchData.sport,
  court: matchData.court,
  matchType: matchData.matchType,
  assignAdmin: matchData.assignAdmin,
});

        previousRoundMatches.push(matchData);
        createdMatches.push(matchData);
      }

      // ======================================================
      // 6) CREATE FUTURE ROUNDS (PLACEHOLDER MATCHES)
      // ======================================================
      while (previousRoundMatches.length > 1) {
        roundIndex++;

        const nextRoundMatchCount = previousRoundMatches.length / 2;
        const roundName = getRoundName(nextRoundMatchCount);

        const nextRoundMatches = [];

        for (let i = 0; i < previousRoundMatches.length; i += 2) {
          const matchRef = db.ref("matches").push();

          const placeholderMatch = {
            matchId: matchRef.key,
            tournamentId,
            collegeId,
            name: `Winner Match ${i + 1} vs Winner Match ${i + 2}`,
            teamA: "TBD",
            teamB: "TBD",
            court: "TBD",
            matchType: "knockout",
            sport: (tournament.sport || teams[0]?.sport || "").toLowerCase(),
            status: "upcoming",
            assignAdmin: false,
            assigned_admin: null,
            startedAt: null,
            endedAt: null,
            createdAt: Date.now(),

            // Bracket fields
            isBracketMatch: true,
            round: roundName,
            roundIndex,
            bracketOrder: nextRoundMatches.length + 1,
            nextMatchId: null,
            winner: null,
          };

          // Save full match in global matches root
          await matchRef.set(placeholderMatch);

          // Save lightweight reference inside tournament node
          await db.ref(`${tournamentMatchesPath}/${matchRef.key}`).set({
  matchId: matchRef.key,
  tournamentId,
  collegeId,
  name: placeholderMatch.name,
  teamA: placeholderMatch.teamA,
  teamB: placeholderMatch.teamB,
  round: placeholderMatch.round,
  roundIndex: placeholderMatch.roundIndex,
  bracketOrder: placeholderMatch.bracketOrder,
  status: placeholderMatch.status,
  isBracketMatch: true,
  sport: placeholderMatch.sport,
  court: placeholderMatch.court,
  matchType: placeholderMatch.matchType,
  assignAdmin: placeholderMatch.assignAdmin,
  createdAt: placeholderMatch.createdAt,
});

          const prev1 = previousRoundMatches[i];
          const prev2 = previousRoundMatches[i + 1];

          // Link previous matches to next match
          await db.ref(`matches/${prev1.matchId}/nextMatchId`).set(matchRef.key);
          await db.ref(`matches/${prev2.matchId}/nextMatchId`).set(matchRef.key);

          nextRoundMatches.push(placeholderMatch);
          createdMatches.push(placeholderMatch);
        }

        previousRoundMatches = nextRoundMatches;
      }

      return res.status(201).json({
        message: "Bracket generated successfully",
        tournamentId,
        collegeId,
        totalTeams: originalCount,
        bracketSize,
        byeCount,
        matchesCreated: createdMatches.length,
        matches: createdMatches,
      });
    } catch (error) {
      console.error("❌ Generate bracket error:", error);
      return res.status(500).json({
        message: "Failed to generate bracket",
        error: error.message,
      });
    }
  }
);

// ==========================================================
// GET /superadmin/tournament/:tournamentId/bracket
// ==========================================================
router.get(
  "/superadmin/tournament/:tournamentId/bracket",
  authMiddleware,
  async (req, res) => {
    try {
      const { tournamentId } = req.params;
      const collegeId = req.user?.collegeId;

      if (!collegeId) {
        return res.status(400).json({
          message: "collegeId missing in auth token",
        });
      }

      // Fetch from global matches root (main source of truth)
      const matchesSnap = await db
        .ref("matches")
        .orderByChild("tournamentId")
        .equalTo(tournamentId)
        .once("value");

      if (!matchesSnap.exists()) {
        return res.status(200).json([]);
      }

      const matchesObj = matchesSnap.val();

      const bracketMatches = Object.keys(matchesObj)
        .map((key) => ({
          ...matchesObj[key],
        }))
        .filter(
          (m) =>
            m.isBracketMatch === true &&
            (m.collegeId || "") === collegeId
        )
        .sort((a, b) => {
          if ((a.roundIndex || 0) !== (b.roundIndex || 0)) {
            return (a.roundIndex || 0) - (b.roundIndex || 0);
          }
          return (a.bracketOrder || 0) - (b.bracketOrder || 0);
        });

      return res.status(200).json(bracketMatches);
    } catch (error) {
      console.error("❌ Fetch bracket error:", error);
      return res.status(500).json({
        message: "Failed to fetch bracket",
        error: error.message,
      });
    }
  }
);

export default router;