export default function badminton(match, event) {
  const score = match.score
    ? JSON.parse(JSON.stringify(match.score))
    : {
        setsA: 0,
        setsB: 0,
        currentSet: { A: 0, B: 0 },
      };

  // 🟢 POINT EVENT
  if (event.type === "POINT") {
    if (event.team === match.teamA) {
      score.currentSet.A += event.value;
    } else if (event.team === match.teamB) {
      score.currentSet.B += event.value;
    }
  }

  // 🟡 CHECK SET WIN
  const a = score.currentSet.A;
  const b = score.currentSet.B;

  const isSetWon =
    (a >= 21 || b >= 21) &&
    Math.abs(a - b) >= 2 ||
    a === 30 ||
    b === 30;

  if (isSetWon) {
    if (a > b) {
      score.setsA += 1;
    } else {
      score.setsB += 1;
    }

    // 🔄 RESET CURRENT SET
    score.currentSet = { A: 0, B: 0 };
  }

  // 🔴 CHECK MATCH WIN (BEST OF 3)
  if (score.setsA === 2) {
    score.winner = match.teamA;
  } else if (score.setsB === 2) {
    score.winner = match.teamB;
  }

  return { score };
}
