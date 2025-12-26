abstract class AdminMatchesEvent {}

class LoadAdminMatches extends AdminMatchesEvent {
  final String adminId;

  LoadAdminMatches(this.adminId);
}
