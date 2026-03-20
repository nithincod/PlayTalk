import 'package:equatable/equatable.dart';
import 'package:playtalk_app/features/match_admin/domain/models/match_admin_user_model.dart';


abstract class AssignMatchAdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AssignMatchAdminInitial extends AssignMatchAdminState {}

class AssignMatchAdminLoading extends AssignMatchAdminState {}

class MatchAdminsLoaded extends AssignMatchAdminState {
  final List<MatchAdminUserModel> admins;

  MatchAdminsLoaded(this.admins);

  @override
  List<Object?> get props => [admins];
}

class AssignMatchAdminSuccess extends AssignMatchAdminState {}

class AssignMatchAdminFailure extends AssignMatchAdminState {
  final String message;

  AssignMatchAdminFailure(this.message);

  @override
  List<Object?> get props => [message];
}