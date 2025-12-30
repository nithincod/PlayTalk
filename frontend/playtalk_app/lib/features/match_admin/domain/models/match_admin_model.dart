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
  });

  factory MatchAdminModel.fromJson(Map<String, dynamic> json) {
    return MatchAdminModel(
      collegeId: json['collegeId'],
      matchId: json['matchId'],
      name: json['name'] ?? '',
      teamA: json['teamA'] ?? '',
      teamB: json['teamB'] ?? '',
      matchType: json['matchType'] ?? '',
      court: json['court'] ?? '',
      tournamentId: json['tournamentId'] ?? '',
      status: json['status'] ?? 'upcoming', 
      sport: json['sport'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        matchId,
        name,
        teamA,
        teamB,
        matchType,
        court,
        tournamentId,
        status,// 🔥 THIS WAS THE MISSING PIECE
        sport, 
      ];
}
