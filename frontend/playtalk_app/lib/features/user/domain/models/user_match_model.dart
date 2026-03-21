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
  final String status;

  final int teamAScore;
  final int teamBScore;

  // 🔥 Stream fields
  final bool isStreaming;
  final String streamKey;
  final String hlsUrl;

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
    required this.status,
    required this.teamAScore,
    required this.teamBScore,
    required this.isStreaming,
    required this.streamKey,
    required this.hlsUrl,
  });

  static int _toInt(dynamic value) {
    return int.tryParse((value ?? 0).toString()) ?? 0;
  }

  factory UserMatchModel.fromJson(Map<String, dynamic> json) {
    final rawScore = json["score"];
    int a = _toInt(json["teamAScore"]);
    int b = _toInt(json["teamBScore"]);

    if (rawScore is Map) {
      final score = Map<String, dynamic>.from(rawScore);

      if (score["currentSet"] is Map) {
        final currentSet = Map<String, dynamic>.from(score["currentSet"]);
        a = _toInt(currentSet["A"]);
        b = _toInt(currentSet["B"]);
      } else {
        a = _toInt(
          score["teamA"] ??
              score["teamAScore"] ??
              score["a"] ??
              score["scoreA"] ??
              a,
        );
        b = _toInt(
          score["teamB"] ??
              score["teamBScore"] ??
              score["b"] ??
              score["scoreB"] ??
              b,
        );
      }
    }

    final stream = json["stream"] is Map
        ? Map<String, dynamic>.from(json["stream"])
        : <String, dynamic>{};

    return UserMatchModel(
      matchId: (json["matchId"] ?? "").toString(),
      tournamentId: (json["tournamentId"] ?? "").toString(),
      tournamentName: (json["tournamentName"] ?? "").toString(),
      collegeId: (json["collegeId"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      sport: (json["sport"] ?? "").toString(),
      teamA: (json["teamA"] ?? "").toString(),
      teamB: (json["teamB"] ?? "").toString(),
      court: (json["court"] ?? "").toString(),
      status: (json["status"] ?? "upcoming").toString(),
      teamAScore: a,
      teamBScore: b,
      isStreaming: stream["isStreaming"] == true,
      streamKey: (stream["streamKey"] ?? json["matchId"] ?? "").toString(),
      hlsUrl: (stream["hlsUrl"] ?? "").toString(),
    );
  }
}