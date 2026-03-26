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
      };

  // Ensure backward compatibility if older matches don't have new fields
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

  // Only handle point events
  if (event.type === "POINT") {
    const scoringTeam = event.team;

    // ======================================================
    // 1) UPDATE POINTS
    // ======================================================
    if (scoringTeam === match.teamA) {
      score.currentSet.A += event.value;
    } else if (scoringTeam === match.teamB) {
      score.currentSet.B += event.value;
    }

    // ======================================================
    // 2) UPDATE MOMENTUM
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
  // ======================================================
  const a = score.currentSet.A;
  const b = score.currentSet.B;

  const isSetWon =
    (((a >= 21 || b >= 21) && Math.abs(a - b) >= 2) ||
      a === 30 ||
      b === 30);

  if (isSetWon) {
    const setNumber = (score.setsA || 0) + (score.setsB || 0) + 1;

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

    // Store completed set snapshot BEFORE reset
    score.lastCompletedSet = {
      winner: setWinner,
      loser: setLoser,
      scoreA: a,
      scoreB: b,
      setNumber,
    };

    // Reset current set
    score.currentSet = { A: 0, B: 0 };

    // Optional: reset momentum after a set ends
    score.momentum = {
      team: null,
      streak: 0,
    };
  }

  // ======================================================
  // 4) CHECK MATCH WIN (BEST OF 3)
  // ======================================================
  let winner = null;

  if (score.setsA === 2) {
    winner = match.teamA;
    score.winner = match.teamA;
  } else if (score.setsB === 2) {
    winner = match.teamB;
    score.winner = match.teamB;
  }

  // IMPORTANT:
  // Return top-level winner too, so your existing flow can use it easily
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