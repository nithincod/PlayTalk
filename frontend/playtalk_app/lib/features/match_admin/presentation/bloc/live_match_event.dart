abstract class LiveMatchEvent {}

class StartListeningMatch extends LiveMatchEvent {
  final String collegeId;
  final String tournamentId;
  final String matchId;

  StartListeningMatch({
    required this.collegeId,
    required this.tournamentId,
    required this.matchId,
  });
}

