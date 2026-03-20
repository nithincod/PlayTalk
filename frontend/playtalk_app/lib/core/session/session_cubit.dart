import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_session.dart';

class SessionCubit extends Cubit<AppSession?> {
  SessionCubit() : super(null);

  void setSession(AppSession session) {
    emit(session);
  }

  void clearSession() {
    emit(null);
  }
}