import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/auth/presentation/pages/pending_aproval_page.dart';
import 'package:playtalk_app/features/user/data/datasources/user_matches_remote_datasource.dart';
import 'package:playtalk_app/features/user/presentation/bloc/user_matches_bloc.dart';
import 'package:playtalk_app/features/user/presentation/pages/use_home_styled_page.dart';

import 'core/constants/app_routes.dart';
import 'core/session/session_cubit.dart';
import 'core/session/app_session.dart';

import 'features/auth/presentation/pages/auth_gate_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';

import 'features/super_admin/data/datasources/tournament_remote_datasource.dart';
import 'features/super_admin/data/datasources/match_remote_datasource.dart';
import 'features/super_admin/data/repositories/tournament_repository_impl.dart';
import 'features/super_admin/domain/usecases/create_tournament.dart';
import 'features/super_admin/domain/usecases/get_tournaments.dart';
import 'features/super_admin/presentation/bloc/tournament_bloc.dart';
import 'features/super_admin/presentation/bloc/tournament_event.dart';
import 'features/super_admin/presentation/bloc/match_bloc.dart';
import 'features/super_admin/presentation/pages/super_admin_home_page.dart';

import 'features/match_admin/data/datasources/match_admin_matches_remote_datasource.dart';
import 'features/match_admin/data/datasources/match_lifeycle_remote_datasource.dart';
import 'features/match_admin/presentation/bloc/match_admin_matches_bloc.dart';
import 'features/match_admin/presentation/bloc/match_admin_matches_event.dart';
import 'features/match_admin/presentation/bloc/match_lifecycle_bloc.dart';
import 'features/match_admin/presentation/pages/match_admin_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    BlocProvider(
      create: (_) => SessionCubit(),
      child: const PlayTalkApp(),
    ),
  );
}

class PlayTalkApp extends StatelessWidget {
  const PlayTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.authGate,
      routes: {
        AppRoutes.authGate: (_) => const AuthGatePage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.pendingApproval: (_) => const PendingApprovalPage(),

        AppRoutes.superAdminHome: (_) => const SuperAdminHomeWrapper(),
        AppRoutes.matchAdminHome: (_) => const MatchAdminHomeWrapper(),
        AppRoutes.userHome: (_) => const UserHomeWrapper(),
      },
    );
  }
}

/// ===============================
/// SUPER ADMIN WRAPPER
/// ===============================
class SuperAdminHomeWrapper extends StatelessWidget {
  const SuperAdminHomeWrapper({super.key});

  static const String baseUrl = "http://172.70.105.138:3000";

  @override
  Widget build(BuildContext context) {
    final AppSession? session = context.read<SessionCubit>().state;

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text("No session found")),
      );
    }

    final tournamentDatasource = TournamentRemoteDatasource(
      baseUrl: baseUrl,
      token: session.token,
    );

    final matchDatasource = MatchRemoteDatasource(
      baseUrl: baseUrl,
      token: session.token,
    );

    final tournamentRepo = TournamentRepositoryImpl(tournamentDatasource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TournamentBloc(
            getTournaments: GetTournaments(tournamentRepo),
            createTournament: CreateTournament(tournamentRepo),
          )..add(LoadTournaments()),
        ),
        BlocProvider(
          create: (_) => MatchBloc(matchDatasource),
        ),
      ],
      child: const SuperAdminHomePage(),
    );
  }
}

/// ===============================
/// MATCH ADMIN WRAPPER
/// ===============================
class MatchAdminHomeWrapper extends StatelessWidget {
  const MatchAdminHomeWrapper({super.key});

  static const String baseUrl = "http://172.70.105.138:3000";

  @override
  Widget build(BuildContext context) {
    final AppSession? session = context.read<SessionCubit>().state;

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text("No session found")),
      );
    }

    final adminMatchesDatasource = AdminMatchesRemoteDatasource(
      baseUrl: baseUrl,
      token: session.token,
    );

    final lifecycleDatasource = MatchLifecycleRemoteDatasource(
      baseUrl: baseUrl,
      token: session.token,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AdminMatchesBloc(adminMatchesDatasource)
            ..add(LoadAdminMatches()),
        ),
        BlocProvider(
          create: (_) => MatchLifecycleBloc(lifecycleDatasource),
        ),
      ],
      child: const MatchAdminHomeStyledPage(),
    );
  }
}

/// ===============================
/// USER WRAPPER
/// ===============================
class UserHomeWrapper extends StatelessWidget {
  const UserHomeWrapper({super.key});

  static const String baseUrl = "http://172.70.105.138:3000";

  @override
  Widget build(BuildContext context) {
    final AppSession? session = context.read<SessionCubit>().state;

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text("No session found")),
      );
    }

    final userMatchesDatasource = UserMatchesRemoteDatasource(
      baseUrl: baseUrl,
      token: session.token,
    );

    return BlocProvider(
      create: (_) => UserMatchesBloc(userMatchesDatasource),
      child: const UserHomeStyledPage(),
    );
  }
}