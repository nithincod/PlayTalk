import badminton from "./badminton.rules.js";
// import kabaddi from "./kabaddi.rules.js";

export function applyRules(sport, match, event) {
  if (!sport) {
    console.error("❌ SPORT IS UNDEFINED");
    return {};
  }

  // 🔥 NORMALIZE SPORT VALUE
  const normalizedSport = sport.toLowerCase().trim();

  console.log("APPLY RULES FOR:", normalizedSport);

  switch (normalizedSport) {
    case "badminton":
      return badminton(match, event);

    // case "kabaddi":
    //   return kabaddi(match, event);

    default:
      console.error("❌ NO RULES FOUND FOR SPORT:", sport);
      return {};
  }
}
