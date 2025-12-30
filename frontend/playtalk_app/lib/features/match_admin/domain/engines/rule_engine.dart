class RuleEngine {
  static Map<String, dynamic> applyEvent({
    required String sport,
    required Map<String, dynamic> currentScore,
    required Map<String, dynamic> event,
  }) {
    switch (sport) {
      case "badminton":
        return _badminton(currentScore, event);
      case "kabaddi":
        return _kabaddi(currentScore, event);
      default:
        return currentScore;
    }
  }

  static Map<String, dynamic> _badminton(
    Map<String, dynamic> score,
    Map<String, dynamic> event,
  ) {
    if (event["type"] == "POINT") {
      score[event["team"]] =
          (score[event["team"]] ?? 0) + event["value"];
    }
    return score;
  }

  static Map<String, dynamic> _kabaddi(
    Map<String, dynamic> score,
    Map<String, dynamic> event,
  ) {
    if (event["type"] == "RAID_POINT") {
      score[event["team"]] =
          (score[event["team"]] ?? 0) + event["value"];
    }
    return score;
  }
}
