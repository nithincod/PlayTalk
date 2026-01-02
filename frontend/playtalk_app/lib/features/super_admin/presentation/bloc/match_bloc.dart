import 'package:flutter_bloc/flutter_bloc.dart';
import 'match_event.dart';
import 'match_state.dart';
import '../../data/datasources/match_remote_datasource.dart';
import '../../domain/models/match_model.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final MatchRemoteDatasource datasource;

  MatchBloc(this.datasource) : super(MatchInitial()) {
    on<LoadMatches>((event, emit) async {
      emit(MatchLoading());
      try {
        final raw = await datasource.fetchMatches(event.tournamentId);
        final matches = raw
            .map(
              (e) => MatchModel.fromJson(e),
            )
            .toList();

        emit(MatchLoaded(matches));
      } catch (e) {
        emit(MatchError("Failed to load matches"));
      }
    });
    on<LoadAdminMatches>((event, emit) async {
  emit(MatchLoading());
  try {
    final raw = await datasource.fetchAdminMatches();
    final matches = raw.map((e) => MatchModel.fromJson(e)).toList();
    emit(MatchLoaded(matches));
  } catch (_) {
    emit(MatchError("Failed to load matches"));
  }
});

    on<CreateMatchEvent>((event, emit) async {
      emit(MatchLoading());
      try {
        await datasource.createMatch(
          tournamentId: event.tournamentId,
          name: event.name,
          teamA: event.teamA,
          teamB: event.teamB,
          court: event.court,
          matchType: event.matchType, 
          sport: event.sport,
        );

        add(LoadMatches(event.tournamentId));
      } catch (e) {
        emit(MatchError("Failed to create match"));
      }
    });
  }
}
