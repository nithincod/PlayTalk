abstract class AssignMatchAdminState {}

class AssignMatchAdminInitial extends AssignMatchAdminState {}

class AssignMatchAdminLoading extends AssignMatchAdminState {}

class AssignMatchAdminSuccess extends AssignMatchAdminState {}

class AssignMatchAdminFailure extends AssignMatchAdminState {
  final String message;
  AssignMatchAdminFailure(this.message);
}
