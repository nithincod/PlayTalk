class MatchModel {
  final String matchId;
  final String name;
  final String teamA;
  final String teamB;
  final String matchType;
  final String court;
  final String tournamentId;
  final String status;

  MatchModel({
    required this.matchId,
    required this.name,
    required this.teamA,
    required this.teamB,
    required this.matchType,
    required this.court,
    required this.tournamentId,
    required this.status,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['matchId'],
      name: json['name'] ?? '',
      teamA: json['teamA'] ?? '',
      teamB: json['teamB'] ?? '',
      matchType: json['matchType'] ?? '',
      court: json['court'] ?? '',
      tournamentId: json['tournamentId'] ?? '',
      status: json['status'] ?? 'upcoming',
    );
  }
}

