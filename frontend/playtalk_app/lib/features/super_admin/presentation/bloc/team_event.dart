abstract class TeamEvent {}

class LoadTeams extends TeamEvent {
  final String tournamentId;

  LoadTeams(this.tournamentId);
}

class CreateTeamPressed extends TeamEvent {
  final String tournamentId;
  final String name;
  final String sport;
  final List<String> players;
  final String captain;

  CreateTeamPressed({
    required this.tournamentId,
    required this.name,
    required this.sport,
    required this.players,
    required this.captain,
  });
}

class DeleteTeamPressed extends TeamEvent {
  final String tournamentId;
  final String teamId;

  DeleteTeamPressed({
    required this.tournamentId,
    required this.teamId,
  });
}