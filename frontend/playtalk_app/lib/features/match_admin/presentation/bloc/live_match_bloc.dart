import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/live_match_remote_datasource.dart';
import 'live_match_event.dart';
import 'live_match_state.dart';

class LiveMatchBloc extends Bloc<LiveMatchEvent, LiveMatchState> {
  final LiveMatchRemoteDatasource datasource;
  StreamSubscription? _sub;

  LiveMatchBloc(this.datasource) : super(LiveMatchLoading()) {
    on<StartListeningMatch>((event, emit) async {
      _sub?.cancel();

      _sub = datasource
          .listenMatch(
            event.tournamentId,
            event.matchId,
          )
          .listen((data) {
        emit(
          LiveMatchUpdated(
            match: data['match'],
            score: data['score'],
            events: data['events'],
          ),
        );
      });
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
