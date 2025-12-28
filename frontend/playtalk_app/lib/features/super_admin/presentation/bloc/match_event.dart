abstract class MatchEvent {}

class LoadMatches extends MatchEvent {
  final String tournamentId;
  LoadMatches(this.tournamentId);
}

class CreateMatchEvent extends MatchEvent {
  final String tournamentId;
  final String name;
  final String teamA;
  final String teamB;
  final String court;
  final String matchType;
  final String status;

  CreateMatchEvent({
    required this.tournamentId,
    required this.name,
    required this.teamA,
    required this.teamB,
    required this.court,
    required this.matchType,
    required this.status,
  });
}
