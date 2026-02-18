class MatchModel {
  final String matchId;
  final String sport;
  final String name;
  final String teamA;
  final String teamB;
  final String matchType;
  final String court;
  final String tournamentId;
  final String status;

  // 🔥 admin info (NULL = not assigned)
  final Map<String, dynamic>? assignedAdmin;

  MatchModel({
    required this.matchId,
    required this.sport,
    required this.name,
    required this.teamA,
    required this.teamB,
    required this.matchType,
    required this.court,
    required this.tournamentId,
    required this.status,
    required this.assignedAdmin,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['matchId'] ?? '',
      sport: json['sport'] ?? '',
      name: json['name'] ?? '',
      teamA: json['teamA'] ?? '',
      teamB: json['teamB'] ?? '',
      matchType: json['matchType'] ?? '',
      court: json['court'] ?? '',
      tournamentId: json['tournamentId'] ?? '',
      status: json['status'] ?? 'upcoming',

      // 🔥 IMPORTANT
      assignedAdmin: json['assigned_admin'] != null
          ? Map<String, dynamic>.from(json['assigned_admin'])
          : null,
    );
  }

  /// 🔹 Helper (VERY CLEAN UI LOGIC)
  bool get hasAssignedAdmin => assignedAdmin != null;
}
