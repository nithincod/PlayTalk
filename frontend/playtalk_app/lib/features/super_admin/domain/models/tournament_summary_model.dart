class TournamentSummaryModel {
  final String tournamentId;
  final String name;
  final String sport;
  final String mode;
  final String status;
  final int teamsCount;
  final int matchesCount;
  final List<Map<String, dynamic>> recentMatches;

  TournamentSummaryModel({
    required this.tournamentId,
    required this.name,
    required this.sport,
    required this.mode,
    required this.status,
    required this.teamsCount,
    required this.matchesCount,
    required this.recentMatches,
  });

  factory TournamentSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawRecent = json["recentMatches"];
    final recent = rawRecent is List
        ? rawRecent
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    return TournamentSummaryModel(
      tournamentId: (json["tournamentId"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      sport: (json["sport"] ?? "").toString(),
      mode: (json["mode"] ?? "").toString(),
      status: (json["status"] ?? "active").toString(),
      teamsCount: int.tryParse((json["teamsCount"] ?? 0).toString()) ?? 0,
      matchesCount: int.tryParse((json["matchesCount"] ?? 0).toString()) ?? 0,
      recentMatches: recent,
    );
  }
}