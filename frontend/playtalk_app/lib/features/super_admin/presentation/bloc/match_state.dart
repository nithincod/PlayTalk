import '../../domain/models/match_model.dart';

abstract class MatchState {}

class MatchInitial extends MatchState {}

class MatchLoading extends MatchState {}

class MatchLoaded extends MatchState {
  final List<MatchModel> matches;
  MatchLoaded(this.matches);
}

class MatchError extends MatchState {
  final String message;
  MatchError(this.message);
}
