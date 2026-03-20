class UserMatchModel {
  final String matchId;
  final String tournamentId;
  final String tournamentName;
  final String collegeId;

  final String name;
  final String sport;
  final String teamA;
  final String teamB;
  final String court;
  final String matchType;
  final String status;

  final int teamAScore;
  final int teamBScore;

  UserMatchModel({
    required this.matchId,
    required this.tournamentId,
    required this.tournamentName,
    required this.collegeId,
    required this.name,
    required this.sport,
    required this.teamA,
    required this.teamB,
    required this.court,
    required this.matchType,
    required this.status,
    required this.teamAScore,
    required this.teamBScore,
  });

  factory UserMatchModel.fromJson(Map<String, dynamic> json) {
    return UserMatchModel(
      matchId: json['matchId'] ?? '',
      tournamentId: json['tournamentId'] ?? '',
      tournamentName: json['tournamentName'] ?? '',
      collegeId: json['collegeId'] ?? '',

      name: json['name'] ?? '',
      sport: json['sport'] ?? '',
      teamA: json['teamA'] ?? '',
      teamB: json['teamB'] ?? '',
      court: json['court'] ?? '',
      matchType: json['matchType'] ?? '',
      status: json['status'] ?? 'upcoming',

      // ✅ IMPORTANT: use flat scores from backend
      teamAScore: _toInt(json['teamAScore']),
      teamBScore: _toInt(json['teamBScore']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}