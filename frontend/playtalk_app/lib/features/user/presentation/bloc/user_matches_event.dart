abstract class UserMatchesEvent {}

class StartListeningUserMatches extends UserMatchesEvent {
  final String collegeId;
  StartListeningUserMatches(this.collegeId);
}
