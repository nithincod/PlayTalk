abstract class UserLiveMatchEvent {}

class WatchUserLiveMatch extends UserLiveMatchEvent {
  final String collegeId;
  final String tournamentId;
  final String matchId;

  WatchUserLiveMatch({
    required this.collegeId,
    required this.tournamentId,
    required this.matchId,
  });
}