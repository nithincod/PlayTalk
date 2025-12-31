import '../../domain/models/match_model.dart';

abstract class UserMatchesState {}

class UserMatchesLoading extends UserMatchesState {}

class UserMatchesLoaded extends UserMatchesState {
  final List<MatchModel> matches;
  UserMatchesLoaded(this.matches);
}

class UserMatchesError extends UserMatchesState {
  final String message;
  UserMatchesError(this.message);
}
