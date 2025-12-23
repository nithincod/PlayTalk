import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/tornament_state.dart';
import 'tournament_event.dart';
import '../../domain/usecases/get_tournaments.dart';
import '../../domain/usecases/create_tournament.dart';

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final GetTournaments getTournaments;
  final CreateTournament createTournament;

  TournamentBloc({
    required this.getTournaments,
    required this.createTournament,
  }) : super(TournamentInitial()) {

    on<LoadTournaments>((event, emit) async {
      emit(TournamentLoading());
      try {
        final tournaments = await getTournaments();
        emit(TournamentLoaded(tournaments));
      } catch (e) {
        emit(TournamentError("Failed to load tournaments"));
      }
    });

    on<CreateTournamentEvent>((event, emit) async {
      emit(TournamentLoading());
      try {
        await createTournament(
          name: event.name,
          sport: event.sport,
          mode: event.mode,
        );

        final tournaments = await getTournaments();
        emit(TournamentLoaded(tournaments));
      } catch (e) {
        emit(TournamentError("Failed to create tournament"));
      }
    });
  }
}
