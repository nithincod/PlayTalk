function safeNum(v) {
  return Number(v || 0);
}

function getTeamSide(matchBefore, event) {
  if (event.team === matchBefore.teamA) return "A";
  if (event.team === matchBefore.teamB) return "B";
  return null;
}

export default function generateBadmintonCommentary({
  matchBefore,
  event,
  updatedState,
}) {
  const beforeScore = matchBefore.score || {};
  const afterScore = updatedState.score || {};

  const beforeCurrent = beforeScore.currentSet || { A: 0, B: 0 };
  const afterCurrent = afterScore.currentSet || { A: 0, B: 0 };

  const beforeSetsA = safeNum(beforeScore.setsA);
  const beforeSetsB = safeNum(beforeScore.setsB);

  const afterSetsA = safeNum(afterScore.setsA);
  const afterSetsB = safeNum(afterScore.setsB);

  const teamA = matchBefore.teamA || "Team A";
  const teamB = matchBefore.teamB || "Team B";

  const scoringTeam = event.team || "";
  const side = getTeamSide(matchBefore, event);

  const a = safeNum(afterCurrent.A);
  const b = safeNum(afterCurrent.B);

  const beforeA = safeNum(beforeCurrent.A);
  const beforeB = safeNum(beforeCurrent.B);

  const winner = updatedState.winner || afterScore.winner || null;
  const lastCompletedSet = afterScore.lastCompletedSet || null;
  const momentum = afterScore.momentum || { team: null, streak: 0 };

  // ======================================================
  // 1) MATCH WON
  // ======================================================
  if (winner) {
    return {
      category: "match_point",
      important: true,
      text: `Match point converted! ${winner} wins the match ${afterSetsA}-${afterSetsB} in sets.`,
    };
  }

  // ======================================================
  // 2) SET JUST COMPLETED
  // ======================================================
  const setCompletedNow = afterSetsA > beforeSetsA || afterSetsB > beforeSetsB;

  if (setCompletedNow && lastCompletedSet) {
    const setNo = safeNum(lastCompletedSet.setNumber);
    const setWinner = lastCompletedSet.winner || scoringTeam;
    const scoreA = safeNum(lastCompletedSet.scoreA);
    const scoreB = safeNum(lastCompletedSet.scoreB);

    const isDeuceBattle =
      (scoreA >= 20 && scoreB >= 20) || scoreA >= 22 || scoreB >= 22;

    return {
      category: "set_win",
      important: true,
      text: isDeuceBattle
          ? `${setWinner} steals Set ${setNo} ${scoreA}-${scoreB} after a tense deuce battle.`
          : `${setWinner} takes Set ${setNo} ${scoreA}-${scoreB}.`,
    };
  }

  // ======================================================
  // 3) SET POINT
  // ======================================================
  if (side === "A") {
    if ((a === 20 && b <= 18) || (a === 29 && b === 28)) {
      return {
        category: "set_point",
        important: true,
        text: `Set point for ${teamA} at ${a}-${b}.`,
      };
    }
  }

  if (side === "B") {
    if ((b === 20 && a <= 18) || (b === 29 && a === 28)) {
      return {
        category: "set_point",
        important: true,
        text: `Set point for ${teamB} at ${a}-${b}.`,
      };
    }
  }

  // ======================================================
  // 4) DEUCE / PRESSURE
  // ======================================================
  if (a >= 20 && b >= 20 && Math.abs(a - b) <= 1) {
    return {
      category: "pressure",
      important: true,
      text: `We're deep into a pressure situation at ${a}-${b} in this set!`,
    };
  }

  // ======================================================
  // 5) MOMENTUM SWING
  // ======================================================
  if (momentum.team && safeNum(momentum.streak) >= 3) {
    return {
      category: "momentum",
      important: safeNum(momentum.streak) >= 4,
      text:
        safeNum(momentum.streak) >= 4
          ? `Massive momentum swing! ${momentum.team} has taken ${momentum.streak} straight points.`
          : `${momentum.team} is building pressure with ${momentum.streak} points in a row.`,
    };
  }

  // ======================================================
  // 6) COMEBACK ALERT
  // ======================================================
  const beforeDiff = beforeA - beforeB;
  const afterDiff = a - b;

  if (beforeDiff <= -4 && afterDiff >= -1) {
    return {
      category: "comeback",
      important: true,
      text: `Comeback alert! ${teamA} has fought back brilliantly to ${a}-${b}.`,
    };
  }

  if (beforeDiff >= 4 && afterDiff <= 1) {
    return {
      category: "comeback",
      important: true,
      text: `Comeback alert! ${teamB} has clawed back into the set at ${a}-${b}.`,
    };
  }

  // ======================================================
  // 7) BIG LEAD / CONTROL
  // ======================================================
  if (Math.abs(a - b) >= 5 && (a >= 11 || b >= 11)) {
    const leader = a > b ? teamA : teamB;
    return {
      category: "dominance",
      important: false,
      text: `${leader} is taking control of this set at ${a}-${b}.`,
    };
  }

  // ======================================================
  // 8) TIGHT SET
  // ======================================================
  if (Math.abs(a - b) <= 2 && (a + b) >= 8) {
    return {
      category: "point",
      important: false,
      text: `${scoringTeam} edges ahead at ${a}-${b} in a very tight set.`,
    };
  }

  // ======================================================
  // 9) DEFAULT
  // ======================================================
  return {
    category: "point",
    important: false,
    text: `${scoringTeam} wins the point. Current set score: ${a}-${b}.`,
  };
}