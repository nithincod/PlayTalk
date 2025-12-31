class MatchModel {
  final String matchId;
  final String tournamentId;
  final String name;
  final String teamA;
  final String teamB;
  final String sport;
  final String status;

  MatchModel({
    required this.matchId,
    required this.tournamentId,
    required this.name,
    required this.teamA,
    required this.teamB,
    required this.sport,
    required this.status,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['matchId'],
      tournamentId: json['tournamentId'],
      name: json['name'] ?? '',
      teamA: json['teamA'] ?? '',
      teamB: json['teamB'] ?? '',
      sport: json['sport'] ?? '',
      status: json['status'] ?? 'upcoming',
    );
  }
}
