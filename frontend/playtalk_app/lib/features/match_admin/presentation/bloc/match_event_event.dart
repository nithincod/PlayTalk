abstract class MatchEventEvent {}

class SubmitMatchEvent extends MatchEventEvent {
  final String tournamentId;
  final String matchId;
  final Map<String, dynamic> event;

  SubmitMatchEvent({
    required this.tournamentId,
    required this.matchId,
    required this.event,
  });
}
