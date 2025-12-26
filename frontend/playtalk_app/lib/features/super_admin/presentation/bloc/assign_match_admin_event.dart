abstract class AssignMatchAdminEvent {}

class AssignMatchAdminPressed extends AssignMatchAdminEvent {
  final String matchId;
  final String adminId;
  final String adminName;
  final String tournamentId;

  AssignMatchAdminPressed({
    required this.tournamentId,
    required this.matchId,
    required this.adminId,
    required this.adminName,
  });
}
