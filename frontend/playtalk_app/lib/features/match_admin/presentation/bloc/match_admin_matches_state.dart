import 'package:equatable/equatable.dart';
import '../../domain/models/match_model.dart';

abstract class AdminMatchesState extends Equatable {
  const AdminMatchesState();

  @override
  List<Object?> get props => [];
}

class AdminMatchesInitial extends AdminMatchesState {}

class AdminMatchesLoading extends AdminMatchesState {}

class AdminMatchesLoaded extends AdminMatchesState {
  final List<MatchModel> matches;

  const AdminMatchesLoaded(this.matches);

  @override
  List<Object?> get props => [matches];
}

class AdminMatchesError extends AdminMatchesState {
  final String message;

  const AdminMatchesError(this.message);

  @override
  List<Object?> get props => [message];
}
