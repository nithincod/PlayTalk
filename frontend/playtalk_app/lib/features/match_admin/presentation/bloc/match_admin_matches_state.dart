import 'package:playtalk_app/features/match_admin/domain/models/match_model.dart';

abstract class AdminMatchesState {}

class AdminMatchesInitial extends AdminMatchesState {}

class AdminMatchesLoading extends AdminMatchesState {}

class AdminMatchesLoaded extends AdminMatchesState {
  final List<MatchModel> matches;

  AdminMatchesLoaded(this.matches);
}

class AdminMatchesError extends AdminMatchesState {
  final String message;

  AdminMatchesError(this.message);
}
