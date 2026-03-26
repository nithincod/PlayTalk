export default function badminton(match, event) {
  const score = match.score
    ? JSON.parse(JSON.stringify(match.score))
    : {
        setsA: 0,
        setsB: 0,
        currentSet: { A: 0, B: 0 },
        lastCompletedSet: null,
        lastPointBy: null,
        momentum: {
          team: null,
          streak: 0,
        },
        winner: null,
      };

  // ======================================================
  // BACKWARD COMPATIBILITY FOR OLDER MATCHES
  // ======================================================
  if (score.setsA === undefined || score.setsA === null) {
    score.setsA = 0;
  }

  if (score.setsB === undefined || score.setsB === null) {
    score.setsB = 0;
  }

  if (!score.currentSet) {
    score.currentSet = { A: 0, B: 0 };
  }

  if (!score.momentum) {
    score.momentum = {
      team: null,
      streak: 0,
    };
  }

  if (score.lastCompletedSet === undefined) {
    score.lastCompletedSet = null;
  }

  if (score.lastPointBy === undefined) {
    score.lastPointBy = null;
  }

  if (score.winner === undefined) {
    score.winner = null;
  }

  // ======================================================
  // ONLY HANDLE POINT EVENTS
  // ======================================================
  if (event.type === "POINT") {
    const scoringTeam = event.team;
    const pointValue = Number(event.value || 1);

    // ======================================================
    // 1) UPDATE CURRENT SET POINTS
    // ======================================================
    if (scoringTeam === match.teamA) {
      score.currentSet.A += pointValue;
    } else if (scoringTeam === match.teamB) {
      score.currentSet.B += pointValue;
    }

    // ======================================================
    // 2) UPDATE MOMENTUM (CONSECUTIVE POINTS)
    // ======================================================
    if (score.lastPointBy === scoringTeam) {
      score.momentum.team = scoringTeam;
      score.momentum.streak = (score.momentum.streak || 0) + 1;
    } else {
      score.momentum.team = scoringTeam;
      score.momentum.streak = 1;
    }

    score.lastPointBy = scoringTeam;
  }

  // ======================================================
  // 3) CHECK SET WIN
  // Badminton:
  // - First to 21 with 2-point lead
  // - Cap at 30
  // ======================================================
  const a = Number(score.currentSet.A || 0);
  const b = Number(score.currentSet.B || 0);

  const isSetWon =
    (((a >= 21 || b >= 21) && Math.abs(a - b) >= 2) ||
      a === 30 ||
      b === 30);

  if (isSetWon) {
    const setNumber = Number(score.setsA || 0) + Number(score.setsB || 0) + 1;

    let setWinner = null;
    let setLoser = null;

    if (a > b) {
      score.setsA += 1;
      setWinner = match.teamA;
      setLoser = match.teamB;
    } else {
      score.setsB += 1;
      setWinner = match.teamB;
      setLoser = match.teamA;
    }

    // ======================================================
    // STORE COMPLETED SET SNAPSHOT BEFORE RESET
    // ======================================================
    score.lastCompletedSet = {
      winner: setWinner,
      loser: setLoser,
      scoreA: a,
      scoreB: b,
      setNumber,
      endedAt: Date.now(),
    };

    // ======================================================
    // RESET CURRENT SET FOR NEXT SET
    // ======================================================
    score.currentSet = { A: 0, B: 0 };

    // Reset momentum after set ends
    score.momentum = {
      team: null,
      streak: 0,
    };

    // Optional: keep lastPointBy as set winner
    score.lastPointBy = setWinner;
  }

  // ======================================================
  // 4) CHECK MATCH WIN (BEST OF 3)
  // First to 2 sets
  // ======================================================
  let winner = null;

  if (score.setsA === 2) {
    winner = match.teamA;
    score.winner = match.teamA;
  } else if (score.setsB === 2) {
    winner = match.teamB;
    score.winner = match.teamB;
  }

  // ======================================================
  // IMPORTANT:
  // Return top-level winner for your existing flow
  // This is REQUIRED for your current submitMatchEvent logic
  // ======================================================
  if (winner) {
    return {
      score,
      winner,
      status: "finished",
      endedAt: Date.now(),
    };
  }

  return { score };
}