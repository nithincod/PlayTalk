import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/match_event_remote_datasource.dart';
import 'match_event_event.dart';
import 'match_event_state.dart';

class MatchEventBloc extends Bloc<MatchEventEvent, MatchEventState> {
  final MatchEventRemoteDatasource datasource;

  MatchEventBloc(this.datasource) : super(MatchEventInitial()) {
    on<SubmitMatchEvent>((event, emit) async {
      emit(MatchEventLoading());
      try {
        await datasource.submitEvent(
          tournamentId: event.tournamentId,
          matchId: event.matchId,
          event: event.event,
        );
        emit(MatchEventSuccess());
      } catch (e) {
        emit(MatchEventFailure("Failed to submit event"));
      }
    });
  }
}
