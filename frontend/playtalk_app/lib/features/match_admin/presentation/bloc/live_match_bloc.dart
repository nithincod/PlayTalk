import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/live_match_remote_datasource.dart';
import 'live_match_event.dart';
import 'live_match_state.dart';

class LiveMatchBloc extends Bloc<LiveMatchEvent, LiveMatchState> {
  final LiveMatchRemoteDatasource datasource;

  LiveMatchBloc(this.datasource) : super(LiveMatchLoading()) {
    on<StartListeningMatch>(_onStartListeningMatch);
  }

  Future<void> _onStartListeningMatch(
    StartListeningMatch event,
    Emitter<LiveMatchState> emit,
  ) async {
    // 🔥 Correct way to bind a stream to bloc lifecycle
    await emit.forEach<Map<String, dynamic>>(
      datasource.listenMatch(
        event.collegeId,
        event.tournamentId,
        event.matchId,
      ),
      onData: (data) {
        return LiveMatchUpdated(
          match: Map<String, dynamic>.from(data['match']),
          score: Map<String, dynamic>.from(data['score']),
          events: List<Map<String, dynamic>>.from(data['events']),
        );
      },
      onError: (error, stackTrace) {
        return LiveMatchError(error.toString());
      },
    );
  }
}
