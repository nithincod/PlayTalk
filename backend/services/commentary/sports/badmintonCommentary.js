function getSafeScore(score) {
  return score || {
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
}

function getTeamSide(match, teamName) {
  if (teamName === match.teamA) return "A";
  if (teamName === match.teamB) return "B";
  return null;
}

function isDeuce(a, b) {
  return a >= 20 && b >= 20;
}

function isGamePointForA(a, b) {
  if (a === 30) return true;
  if (a >= 20 && a - b === 1) return true;
  return false;
}

function isGamePointForB(a, b) {
  if (b === 30) return true;
  if (b >= 20 && b - a === 1) return true;
  return false;
}

function buildRegularPointLine(scoringTeam, a, b) {
  const diff = Math.abs(a - b);

  if (a === b) {
    if (a >= 18) {
      return `${scoringTeam} draws level at ${a}-${b} — this set is getting intense!`;
    }
    return `${scoringTeam} makes it ${a}-${b}. We are all square.`;
  }

  if (diff >= 4) {
    return `${scoringTeam} extends the lead to ${a}-${b} and is in control of this phase.`;
  }

  if (diff === 1) {
    return `${scoringTeam} edges ahead at ${a}-${b} in a very tight set.`;
  }

  return `${scoringTeam} takes the point and moves to ${a}-${b}.`;
}

function buildDeuceLine(a, b) {
  return `Locked at ${a}-${b} — two clear points needed now to take the set!`;
}

function buildGamePointLine(teamName, a, b) {
  return `Game point for ${teamName} at ${a}-${b} — huge pressure on the next rally.`;
}

function buildSetWinLine(match, afterScore) {
  const lastSet = afterScore.lastCompletedSet;

  if (!lastSet) {
    const setsA = afterScore.setsA || 0;
    const setsB = afterScore.setsB || 0;
    const winner = setsA > setsB ? match.teamA : match.teamB;
    return `${winner} takes the set and now leads ${setsA}-${setsB} in sets.`;
  }

  const { winner, scoreA, scoreB, setNumber } = lastSet;
  const setsA = afterScore.setsA || 0;
  const setsB = afterScore.setsB || 0;

  if (setNumber === 1) {
    return `${winner} takes the opening set ${scoreA}-${scoreB} and leads 1-0.`;
  }

  if (setsA === setsB) {
    return `${winner} wins set ${setNumber} by ${scoreA}-${scoreB} and levels the match at ${setsA}-${setsB}.`;
  }

  return `${winner} claims set ${setNumber} ${scoreA}-${scoreB} and now leads ${setsA}-${setsB} in sets.`;
}

function buildMatchWinLine(match, afterScore) {
  const setsA = afterScore.setsA || 0;
  const setsB = afterScore.setsB || 0;
  const winner = afterScore.winner || (setsA > setsB ? match.teamA : match.teamB);

  const lastSet = afterScore.lastCompletedSet;

  if (lastSet) {
    return `${winner} closes out the match by taking the final set ${lastSet.scoreA}-${lastSet.scoreB}! Final sets score: ${setsA}-${setsB}.`;
  }

  return `${winner} seals the match in style! Final sets score: ${setsA}-${setsB}.`;
}

function buildMomentumLine(scoringTeam, streak, a, b) {
  if (streak >= 5) {
    return `${scoringTeam} is on a huge ${streak}-point run and surges ahead at ${a}-${b}!`;
  }

  if (streak >= 3) {
    return `${scoringTeam} makes it ${streak} straight points and builds momentum at ${a}-${b}.`;
  }

  return null;
}

function buildMomentumBreakLine(scoringTeam, a, b) {
  return `${scoringTeam} breaks the momentum and gets a crucial point at ${a}-${b}.`;
}

export default function generateBadmintonCommentary({
  matchBefore,
  event,
  updatedState,
}) {
  if (!updatedState?.score) return null;
  if (event.type !== "POINT") return null;

  const beforeScore = getSafeScore(matchBefore.score);
  const afterScore = getSafeScore(updatedState.score);

  const beforeSetsA = beforeScore.setsA ?? 0;
  const beforeSetsB = beforeScore.setsB ?? 0;

  const afterSetsA = afterScore.setsA ?? 0;
  const afterSetsB = afterScore.setsB ?? 0;

  const afterA = afterScore.currentSet?.A ?? 0;
  const afterB = afterScore.currentSet?.B ?? 0;

  const side = getTeamSide(matchBefore, event.team);
  if (!side) return null;

  // ======================================================
  // 1) MATCH WIN
  // ======================================================
  if (afterScore.winner || updatedState.winner) {
    return {
      text: buildMatchWinLine(matchBefore, afterScore),
      category: "match_win",
      important: true,
    };
  }

  // ======================================================
  // 2) SET WIN
  // ======================================================
  const setWon =
    afterSetsA > beforeSetsA || afterSetsB > beforeSetsB;

  if (setWon) {
    return {
      text: buildSetWinLine(matchBefore, afterScore),
      category: "set_win",
      important: true,
    };
  }

  // ======================================================
  // 3) DEUCE
  // ======================================================
  if (isDeuce(afterA, afterB)) {
    return {
      text: buildDeuceLine(afterA, afterB),
      category: "deuce",
      important: true,
    };
  }

  // ======================================================
  // 4) GAME POINT
  // ======================================================
  if (isGamePointForA(afterA, afterB)) {
    return {
      text: buildGamePointLine(matchBefore.teamA, afterA, afterB),
      category: "game_point",
      important: true,
    };
  }

  if (isGamePointForB(afterA, afterB)) {
    return {
      text: buildGamePointLine(matchBefore.teamB, afterA, afterB),
      category: "game_point",
      important: true,
    };
  }

  // ======================================================
  // 5) MOMENTUM BREAK
  // If previous streak was 3+ by other team, and this team scores now
  // ======================================================
  const previousMomentumTeam = beforeScore.momentum?.team;
  const previousMomentumStreak = beforeScore.momentum?.streak ?? 0;

  if (
    previousMomentumTeam &&
    previousMomentumTeam !== event.team &&
    previousMomentumStreak >= 3
  ) {
    return {
      text: buildMomentumBreakLine(event.team, afterA, afterB),
      category: "momentum_break",
      important: false,
    };
  }

  // ======================================================
  // 6) MOMENTUM RUN
  // ======================================================
  const streak = afterScore.momentum?.streak ?? 0;

  if (streak >= 3) {
    const momentumLine = buildMomentumLine(event.team, streak, afterA, afterB);
    if (momentumLine) {
      return {
        text: momentumLine,
        category: "momentum",
        important: streak >= 5,
      };
    }
  }

  // ======================================================
  // 7) REGULAR POINT
  // ======================================================
  return {
    text: buildRegularPointLine(event.team, afterA, afterB),
    category: "point",
    important: false,
  };
}