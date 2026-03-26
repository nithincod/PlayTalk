import 'package:equatable/equatable.dart';

class BracketMatchModel extends Equatable {
  final String matchId;
  final String tournamentId;
  final String name;
  final String teamA;
  final String teamB;
  final String court;
  final String sport;
  final String status;
  final String round;
  final int roundIndex;
  final int bracketOrder;
  final bool isBracketMatch;
  final String? nextMatchId;
  final String? winner;

  const BracketMatchModel({
    required this.matchId,
    required this.tournamentId,
    required this.name,
    required this.teamA,
    required this.teamB,
    required this.court,
    required this.sport,
    required this.status,
    required this.round,
    required this.roundIndex,
    required this.bracketOrder,
    required this.isBracketMatch,
    required this.nextMatchId,
    required this.winner,
  });

  factory BracketMatchModel.fromJson(Map<String, dynamic> json) {
    return BracketMatchModel(
      matchId: (json['matchId'] ?? '').toString(),
      tournamentId: (json['tournamentId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      teamA: (json['teamA'] ?? '').toString(),
      teamB: (json['teamB'] ?? '').toString(),
      court: (json['court'] ?? '').toString(),
      sport: (json['sport'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      round: (json['round'] ?? '').toString(),
      roundIndex: int.tryParse((json['roundIndex'] ?? 0).toString()) ?? 0,
      bracketOrder: int.tryParse((json['bracketOrder'] ?? 0).toString()) ?? 0,
      isBracketMatch: json['isBracketMatch'] == true,
      nextMatchId: json['nextMatchId']?.toString(),
      winner: json['winner']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        matchId,
        tournamentId,
        name,
        teamA,
        teamB,
        court,
        sport,
        status,
        round,
        roundIndex,
        bracketOrder,
        isBracketMatch,
        nextMatchId,
        winner,
      ];
}