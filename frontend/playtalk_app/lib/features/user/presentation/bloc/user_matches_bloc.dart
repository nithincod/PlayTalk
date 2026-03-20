import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/user_matches_remote_datasource.dart';
import 'user_matches_event.dart';
import 'user_matches_state.dart';

class UserMatchesBloc extends Bloc<UserMatchesEvent, UserMatchesState> {
  final UserMatchesRemoteDatasource datasource;

  UserMatchesBloc(this.datasource) : super(UserMatchesInitial()) {
    on<LoadUserMatches>((event, emit) async {
      emit(UserMatchesLoading());
      try {
        final matches = await datasource.fetchUserMatches();
        emit(UserMatchesLoaded(matches));
      } catch (e) {
        emit(UserMatchesError("Failed to load matches"));
      }
    });
  }
}