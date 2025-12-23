import '../../domain/models/tournament_model.dart';

abstract class TournamentState {}

class TournamentInitial extends TournamentState {}

class TournamentLoading extends TournamentState {}

class TournamentLoaded extends TournamentState {
  final List<TournamentModel> tournaments;
  TournamentLoaded(this.tournaments);
}

class TournamentError extends TournamentState {
  final String message;
  TournamentError(this.message);
}

class TournamentActionSuccess extends TournamentState {
  final String message;
  TournamentActionSuccess(this.message);
}

