import '../../domain/models/user_match_model.dart';

abstract class UserMatchesState {}

class UserMatchesInitial extends UserMatchesState {}

class UserMatchesLoading extends UserMatchesState {}

class UserMatchesLoaded extends UserMatchesState {
  final List<UserMatchModel> matches;

  UserMatchesLoaded(this.matches);
}

class UserMatchesError extends UserMatchesState {
  final String message;

  UserMatchesError(this.message);
}