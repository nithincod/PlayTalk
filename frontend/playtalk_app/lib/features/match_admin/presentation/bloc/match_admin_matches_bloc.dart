import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/match_admin_matches_remote_datasource.dart';
import 'match_admin_matches_event.dart';
import 'match_admin_matches_state.dart';


class AdminMatchesBloc
    extends Bloc<AdminMatchesEvent, AdminMatchesState> {
  final AdminMatchesRemoteDatasource datasource;

  AdminMatchesBloc(this.datasource) : super(AdminMatchesInitial()) {
    on<LoadAdminMatches>((event, emit) async {
      emit(AdminMatchesLoading());
      try {
        final matches =
            await datasource.getAssignedMatches(event.adminId);
        emit(AdminMatchesLoaded(matches));
      } catch (e) {
        emit(AdminMatchesError("Failed to load matches"));
      }
    });
  }
}
