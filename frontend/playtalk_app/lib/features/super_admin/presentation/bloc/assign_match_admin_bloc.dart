import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/assign_match_admin_remote_datasource.dart';
import 'assign_match_admin_event.dart';
import 'assign_match_admin_state.dart';

class AssignMatchAdminBloc
    extends Bloc<AssignMatchAdminEvent, AssignMatchAdminState> {
  final AssignMatchAdminRemoteDatasource datasource;

  AssignMatchAdminBloc(this.datasource)
      : super(AssignMatchAdminInitial()) {
    on<AssignMatchAdminPressed>((event, emit) async {
      emit(AssignMatchAdminLoading());
      try {
        await datasource.assignAdmin(
          tournamentId: event.tournamentId,
          matchId: event.matchId,
          adminId: event.adminId,
          adminName: event.adminName,
        );
        emit(AssignMatchAdminSuccess());
      } catch (e) {
        emit(AssignMatchAdminFailure("Assignment failed"));
      }
    });
  }
}
