import 'package:equatable/equatable.dart';

class MatchAdminModel extends Equatable {
  final String matchId;
  final String collegeId;
  final String sport;
  final String name;
  final String teamA;
  final String teamB;
  final String matchType;
  final String court;
  final String tournamentId;
  final String status;

  // 🔥 Stream fields
  final bool isStreaming;
  final String streamKey;
  final String hlsUrl;

  const MatchAdminModel({
    required this.collegeId,
    required this.sport,
    required this.matchId,
    required this.name,
    required this.teamA,
    required this.teamB,
    required this.matchType,
    required this.court,
    required this.tournamentId,
    required this.status,
    required this.isStreaming,
    required this.streamKey,
    required this.hlsUrl,
  });

  factory MatchAdminModel.fromJson(Map<String, dynamic> json) {
    final stream = json['stream'] is Map
        ? Map<String, dynamic>.from(json['stream'])
        : <String, dynamic>{};

    return MatchAdminModel(
      collegeId: (json['collegeId'] ?? '').toString(),
      matchId: (json['matchId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      teamA: (json['teamA'] ?? '').toString(),
      teamB: (json['teamB'] ?? '').toString(),
      matchType: (json['matchType'] ?? '').toString(),
      court: (json['court'] ?? '').toString(),
      tournamentId: (json['tournamentId'] ?? '').toString(),
      status: (json['status'] ?? 'upcoming').toString(),
      sport: (json['sport'] ?? '').toString(),

      // 🔥 Read stream from backend
      isStreaming: stream['isStreaming'] == true,
      streamKey: (stream['streamKey'] ?? json['matchId'] ?? '').toString(),
      hlsUrl: (stream['hlsUrl'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
        matchId,
        collegeId,
        sport,
        name,
        teamA,
        teamB,
        matchType,
        court,
        tournamentId,
        status,

        // 🔥 include stream fields too
        isStreaming,
        streamKey,
        hlsUrl,
      ];
}