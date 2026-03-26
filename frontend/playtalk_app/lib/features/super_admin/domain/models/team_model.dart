import 'package:equatable/equatable.dart';

class TeamModel extends Equatable {
  final String teamId;
  final String tournamentId;
  final String collegeId;
  final String name;
  final String sport;
  final List<String> players;
  final String captain;
  final int createdAt;

  const TeamModel({
    required this.teamId,
    required this.tournamentId,
    required this.collegeId,
    required this.name,
    required this.sport,
    required this.players,
    required this.captain,
    required this.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json["players"];
    final players = rawPlayers is List
        ? rawPlayers.map((e) => e.toString()).toList()
        : <String>[];

    return TeamModel(
      teamId: (json["teamId"] ?? "").toString(),
      tournamentId: (json["tournamentId"] ?? "").toString(),
      collegeId: (json["collegeId"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      sport: (json["sport"] ?? "").toString(),
      players: players,
      captain: (json["captain"] ?? "").toString(),
      createdAt: int.tryParse((json["createdAt"] ?? 0).toString()) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        teamId,
        tournamentId,
        collegeId,
        name,
        sport,
        players,
        captain,
        createdAt,
      ];
}