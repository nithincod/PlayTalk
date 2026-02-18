
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/assign_match_admin_remote_datasource.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/assign_match_admin_event.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/assign_match_admin_state.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/match_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/match_event.dart';
class AssignMatchAdminBloc
    extends Bloc<AssignMatchAdminEvent, AssignMatchAdminState> {
  final AssignMatchAdminRemoteDatasource datasource;

  AssignMatchAdminBloc(this.datasource)
      : super(AssignMatchAdminInitial()) {

    on<LoadMatchAdmins>((event, emit) async {
      emit(AssignMatchAdminLoading());
      try {
        final admins = await datasource.fetchAdmins();
        emit(MatchAdminsLoaded(admins));
      } catch (e) {
        emit(AssignMatchAdminFailure("Failed to load admins"));
      }
    });

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
