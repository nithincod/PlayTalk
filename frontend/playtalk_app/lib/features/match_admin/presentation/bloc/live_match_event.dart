abstract class LiveMatchEvent {}

class StartListeningMatch extends LiveMatchEvent {
  final String tournamentId;
  final String matchId;

  StartListeningMatch({
    required this.tournamentId,
    required this.matchId,
  });
}
