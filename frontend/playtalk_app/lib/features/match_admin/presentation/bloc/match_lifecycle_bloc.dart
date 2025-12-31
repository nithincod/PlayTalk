import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/match_admin/data/datasources/match_lifeycle_remote_datasource.dart';
import 'package:playtalk_app/features/match_admin/presentation/bloc/match_lifecycle_event.dart';
import 'package:playtalk_app/features/match_admin/presentation/bloc/match_lifecycle_state.dart';

class MatchLifecycleBloc
    extends Bloc<MatchLifecycleEvent, MatchLifecycleState> {
  final MatchLifecycleRemoteDatasource datasource;

  MatchLifecycleBloc(this.datasource)
      : super(MatchLifecycleInitial()) {
    on<StartMatchPressed>((event, emit) async {
      emit(MatchLifecycleLoading());
      try {
        await datasource.startMatch(
          event.matchId,
          tournamentId: event.tournamentId,
        );
        emit(MatchLifecycleSuccess());
      } catch (_) {
        emit(MatchLifecycleFailure("Failed to start match"));
      }
    });

    on<EndMatchPressed>((event, emit) async {
  emit(MatchLifecycleLoading());
  try {
    await datasource.endMatch(
      matchId: event.matchId,
      tournamentId: event.tournamentId,
    );
    emit(MatchLifecycleSuccess());
  } catch (_) {
    emit(MatchLifecycleFailure("Failed to end match"));
  }
});

  }
}
