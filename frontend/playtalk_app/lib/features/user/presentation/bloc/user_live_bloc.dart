import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/user_live_match_remote_datasource.dart';
import 'user_live_match_event.dart';
import 'user_live_match_state.dart';

class UserLiveMatchBloc extends Bloc<UserLiveMatchEvent, UserLiveMatchState> {
  final UserLiveMatchRemoteDatasource datasource;

  UserLiveMatchBloc(this.datasource) : super(const UserLiveMatchState()) {
    on<WatchUserLiveMatch>(_onWatchUserLiveMatch);
  }

  Future<void> _onWatchUserLiveMatch(
    WatchUserLiveMatch event,
    Emitter<UserLiveMatchState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
      ),
    );

    await emit.forEach<Map<String, dynamic>>(
      datasource.watchMatch(
        collegeId: event.collegeId,
        tournamentId: event.tournamentId,
        matchId: event.matchId,
      ),
      onData: (matchData) {
        return state.copyWith(
          loading: false,
          error: null,
          match: matchData,
        );
      },
      onError: (_, __) {
        return state.copyWith(
          loading: false,
          error: "Failed to watch match",
        );
      },
    );
  }
}