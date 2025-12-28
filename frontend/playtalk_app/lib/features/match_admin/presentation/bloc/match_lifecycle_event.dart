abstract class MatchLifecycleEvent {}

class StartMatchPressed extends MatchLifecycleEvent {
  final String tournamentId;
  final String matchId;

  StartMatchPressed(this.tournamentId, this.matchId);
}
