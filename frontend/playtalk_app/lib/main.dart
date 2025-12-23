import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/constants/app_routes.dart';
import 'package:playtalk_app/features/match_admin/presentation/pages/match_admin_home_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/super_admin_home_page.dart';
import 'package:playtalk_app/features/user/presentation/pages/user_home_page.dart';

import 'features/auth/presentation/pages/role_loader.dart';
import 'features/commentary/data/datasources/commentary_firebase_datasource.dart';
import 'features/commentary/data/repositories/commentary_repository_impl.dart';
import 'features/commentary/domain/usecases/listen_to_commentary.dart';
import 'features/commentary/presentation/bloc/commentary_bloc.dart';
import 'features/commentary/presentation/bloc/commentary_event.dart';
import 'features/commentary/presentation/pages/live_match_page.dart';
import 'features/super_admin/data/datasources/tournament_remote_datasource.dart';
import 'features/super_admin/data/repositories/tournament_repository_impl.dart';
import 'features/super_admin/domain/usecases/create_tournament.dart';
import 'features/super_admin/domain/usecases/get_tournaments.dart';
import 'features/super_admin/presentation/bloc/tournament_bloc.dart';
import 'features/super_admin/presentation/bloc/tournament_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final datasource = CommentaryFirebaseDataSource();
  final repository = CommentaryRepositoryImpl(datasource);
  final usecase = ListenToCommentary(repository);

  runApp(
    MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) =>
          CommentaryBloc(usecase)..add(StartCommentaryListening()),
    ),
    BlocProvider(
  create: (_) {
    final datasource = TournamentRemoteDatasource(
      baseUrl: "http://10.0.2.2:3000",
      adminId: "-Oh19e8DauETQEhQxB5G",
    );

    final repo = TournamentRepositoryImpl(datasource);

    return TournamentBloc(
      getTournaments: GetTournaments(repo),
      createTournament: CreateTournament(repo),
    )..add(LoadTournaments());
  },
),

  ],
  child: const PlayTalkApp(),
    )


  );
}


class PlayTalkApp extends StatelessWidget {
  const PlayTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.roleLoader,
      routes: {
        AppRoutes.roleLoader: (_) => const RoleLoaderPage(),
        AppRoutes.superAdminHome: (_) => const SuperAdminHomePage(),
        AppRoutes.matchAdminHome: (_) => const MatchAdminHomePage(),
        AppRoutes.userHome: (_) => const UserHomePage(),
        AppRoutes.liveMatch: (_) => const LiveMatchPage(), // 👈 YOUR PAGE
      },
    );
  }
}

