import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/user_matches_remote_datasource.dart';
import '../../domain/models/match_model.dart';
import 'user_matches_event.dart';
import 'user_matches_state.dart';

class UserMatchesBloc extends Bloc<UserMatchesEvent, UserMatchesState> {
  final UserMatchesRemoteDatasource datasource;

  UserMatchesBloc(this.datasource) : super(UserMatchesLoading()) {
    on<StartListeningUserMatches>(_onStartListening);
  }

  Future<void> _onStartListening(
    StartListeningUserMatches event,
    Emitter<UserMatchesState> emit,
  ) async {
    emit(UserMatchesLoading());

    await emit.forEach<List<MatchModel>>(
      datasource.listenAllMatches(collegeId: event.collegeId),
      onData: (matches) {
        final visible =
            matches.where((m) => m.status != "finished").toList();

        return UserMatchesLoaded(visible);
      },
      onError: (_, __) =>
          UserMatchesError("Failed to load matches"),
    );
  }
}
