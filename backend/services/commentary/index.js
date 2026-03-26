import generateBadmintonCommentary from "./sports/badmintonCommentary.js";

export function generateCommentary({ sport, matchBefore, event, updatedState }) {
  const normalizedSport = String(sport || "").trim().toLowerCase();

  switch (normalizedSport) {
    case "badminton":
      return generateBadmintonCommentary({
        matchBefore,
        event,
        updatedState,
      });

    default:
      return null;
  }
}