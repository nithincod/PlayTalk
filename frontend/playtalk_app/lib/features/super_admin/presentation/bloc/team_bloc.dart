import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/team_remote_datasource.dart';
import 'team_event.dart';
import 'team_state.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final TeamRemoteDatasource datasource;

  TeamBloc(this.datasource) : super(TeamInitial()) {
    on<LoadTeams>((event, emit) async {
      emit(TeamLoading());
      try {
        final teams = await datasource.fetchTeams(event.tournamentId);
        emit(TeamLoaded(teams));
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<CreateTeamPressed>((event, emit) async {
      emit(TeamLoading());
      try {
        await datasource.createTeam(
          tournamentId: event.tournamentId,
          name: event.name,
          sport: event.sport,
          players: event.players,
          captain: event.captain,
        );

        emit(TeamActionSuccess("Team created successfully"));

        final teams = await datasource.fetchTeams(event.tournamentId);
        emit(TeamLoaded(teams));
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<DeleteTeamPressed>((event, emit) async {
      emit(TeamLoading());
      try {
        await datasource.deleteTeam(
          tournamentId: event.tournamentId,
          teamId: event.teamId,
        );

        emit(TeamActionSuccess("Team deleted successfully"));

        final teams = await datasource.fetchTeams(event.tournamentId);
        emit(TeamLoaded(teams));
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });
  }
}