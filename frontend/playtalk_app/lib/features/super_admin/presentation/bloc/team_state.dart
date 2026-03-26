import '../../domain/models/team_model.dart';

abstract class TeamState {}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamLoaded extends TeamState {
  final List<TeamModel> teams;

  TeamLoaded(this.teams);
}

class TeamActionSuccess extends TeamState {
  final String message;

  TeamActionSuccess(this.message);
}

class TeamError extends TeamState {
  final String message;

  TeamError(this.message);
}