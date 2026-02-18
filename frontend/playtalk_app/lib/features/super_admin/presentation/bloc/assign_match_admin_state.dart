import '../../domain/models/match_admin_model.dart';

abstract class AssignMatchAdminState {}

class AssignMatchAdminInitial extends AssignMatchAdminState {}

class AssignMatchAdminLoading extends AssignMatchAdminState {}

class MatchAdminsLoaded extends AssignMatchAdminState {
  final List<MatchAdminModel> admins;
  MatchAdminsLoaded(this.admins);
}

class AssignMatchAdminSuccess extends AssignMatchAdminState {}

class AssignMatchAdminFailure extends AssignMatchAdminState {
  final String message;
  AssignMatchAdminFailure(this.message);
}
