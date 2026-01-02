import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/constants/app_routes.dart';
import 'package:playtalk_app/features/match_admin/presentation/pages/match_admin_home_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/match_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/super_admin_home_page.dart';
import 'package:playtalk_app/features/user/data/datasources/user_matches_remote_datasource.dart';
import 'package:playtalk_app/features/user/presentation/bloc/user_matches_bloc.dart';
import 'package:playtalk_app/features/user/presentation/pages/user_dashboard_page.dart';

import 'features/auth/presentation/pages/role_loader.dart';
import 'features/commentary/data/datasources/commentary_firebase_datasource.dart';
import 'features/commentary/data/repositories/commentary_repository_impl.dart';
import 'features/commentary/domain/usecases/listen_to_commentary.dart';
import 'features/commentary/presentation/bloc/commentary_bloc.dart';
import 'features/commentary/presentation/bloc/commentary_event.dart';
// import 'features/commentary/presentation/pages/live_match_page.dart';
import 'features/match_admin/data/datasources/match_lifeycle_remote_datasource.dart';
import 'features/match_admin/presentation/bloc/match_lifecycle_bloc.dart';
import 'features/super_admin/data/datasources/match_remote_datasource.dart';
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
      baseUrl: "http://192.168.1.2:3000",
      adminId: "-Oh19e8DauETQEhQxB5G",
    );

    final repo = TournamentRepositoryImpl(datasource);

    return TournamentBloc(
      getTournaments: GetTournaments(repo),
      createTournament: CreateTournament(repo),
    )..add(LoadTournaments());
  },


),

BlocProvider(
          create: (_) => UserMatchesBloc(
            UserMatchesRemoteDatasource(),
          ),
        ),

        BlocProvider(create:(_)=>MatchBloc(
          MatchRemoteDatasource(
            baseUrl: "http://192.168.1.2:3000",
            adminId: "-Oh19e8DauETQEhQxB5G",
          ),
        )),

        BlocProvider(
          create: (_) => MatchLifecycleBloc(
            MatchLifecycleRemoteDatasource(
              baseUrl: "http://192.168.1.2:3000",
              adminId: "-Oh19pD34L67JX0RbCRr",
            ),
          ),
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
        AppRoutes.matchAdminHome: (_) => const MatchAdminHomeStyledPage(adminId: '-Oh19pD34L67JX0RbCRr',),
        AppRoutes.userHome: (_) => const UserDashboardPage(collegeId: '-Oh17xBpAcfcH0s_4ZB2'),
        // AppRoutes.liveMatch: (_) => const LiveMatchPage(), // 👈 YOUR PAGE
      },
    );
  }
}

