class MatchModel {
  final String matchId;
  final String name;
  final String teamA;
  final String teamB;
  final String matchType;
  final String court;
  final String tournamentId;

  MatchModel({
    required this.matchId,
    required this.name,
    required this.teamA,
    required this.teamB,
    required this.matchType,
    required this.court,
    required this.tournamentId,
  });

  /// 🔹 FROM BACKEND (Firebase / API)
  factory MatchModel.fromJson(Map<String, dynamic> json) {
  return MatchModel(
    matchId: json['matchId'] ?? json['match_id'] ?? '',
    name: json['name'] ?? json['match_name'] ?? '',
    teamA: json['teamA'] ?? json['team_a'] ?? '',
    teamB: json['teamB'] ?? json['team_b'] ?? '',
    matchType: json['matchType'] ?? json['match_type'] ?? '',
    court: json['court'] ?? json['court_no'] ?? '',
    tournamentId:
        json['tournamentId'] ?? json['tournament_id'] ?? '',
  );
}


  /// 🔹 TO BACKEND (future use)
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'name': name,
      'teamA': teamA,
      'teamB': teamB,
      'matchType': matchType,
      'court': court,
      'tournamentId': tournamentId,
    };
  }
}
