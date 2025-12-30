import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/match_admin/data/datasources/live_match_remote_datasource.dart';
import 'package:playtalk_app/features/match_admin/domain/models/match_admin_model.dart';
import 'package:playtalk_app/features/match_admin/presentation/bloc/live_match_bloc.dart';
import 'package:playtalk_app/features/match_admin/presentation/bloc/match_event_bloc.dart';

import 'package:playtalk_app/features/match_admin/presentation/pages/live_match_page.dart';

import '../../data/datasources/match_admin_matches_remote_datasource.dart';
import '../../data/datasources/match_event_remote_datasource.dart';
import '../../data/datasources/match_lifeycle_remote_datasource.dart';

import '../bloc/match_admin_matches_bloc.dart';
import '../bloc/match_admin_matches_event.dart';
import '../bloc/match_admin_matches_state.dart';

import '../bloc/match_lifecycle_bloc.dart';
import '../bloc/match_lifecycle_event.dart';
import '../bloc/match_lifecycle_state.dart';

class AdminHomePage extends StatelessWidget {
  final String adminId;

  const AdminHomePage({
    super.key,
    required this.adminId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 🔹 Assigned matches list
        BlocProvider(
          create: (_) => AdminMatchesBloc(
            AdminMatchesRemoteDatasource("http://192.168.1.6:3000"),
          )..add(LoadAdminMatches(adminId)),
        ),

        // 🔹 Match lifecycle control
        BlocProvider(
          create: (_) => MatchLifecycleBloc(
            MatchLifecycleRemoteDatasource(
              baseUrl: "http://192.168.1.6:3000",
              adminId: adminId,
            ),
          ),
        ),
      ],
      child: BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
        listener: (context, state) {
          if (state is MatchLifecycleSuccess) {
        // 🔥 THIS IS THE FIX
        context.read<AdminMatchesBloc>()
          .add(LoadAdminMatches(adminId));
      }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("My Assigned Matches"),
          ),
          body: BlocBuilder<AdminMatchesBloc, AdminMatchesState>(
            builder: (context, state) {
              if (state is AdminMatchesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AdminMatchesError) {
                return Center(child: Text(state.message));
              }

              if (state is AdminMatchesLoaded) {
                if (state.matches.isEmpty) {
                  return const Center(
                    child: Text("No matches assigned"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.matches.length,
                  itemBuilder: (context, index) {
                    final MatchAdminModel match = state.matches[index];
                    print("MATCH STATUS UI: ${match.status}");


                    final bool isUpcoming = match.status == "upcoming";
                    final bool isLive = match.status == "live";
                    final bool isFinished = match.status == "finished";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("${match.teamA} vs ${match.teamB}"),
                            Text("Court: ${match.court}"),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(
                                match.status.toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: isUpcoming
                                  ? Colors.orange
                                  : isLive
                                      ? Colors.green
                                      : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: BlocBuilder<MatchLifecycleBloc,
                                  MatchLifecycleState>(
                                builder: (context, lifecycleState) {
                                  return ElevatedButton(
                                    onPressed: isFinished
                                        ? null
                                        : () {
                                            if (isUpcoming) {
                                              context
                                                  .read<MatchLifecycleBloc>()
                                                  .add(
                                                    StartMatchPressed(
                                                      match.tournamentId,
                                                        match.matchId),
                                                  );
                                            } else if (isLive) {
                                              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MultiBlocProvider(
      providers: [
        // 🔹 LIVE MATCH BLOC (Firebase real-time listener) ✅ REQUIRED
        BlocProvider(
          create: (_) => LiveMatchBloc(
            LiveMatchRemoteDatasource(),
          ),
        ),

        // 🔹 Match Event Bloc (submit events)
        BlocProvider(
          create: (_) => MatchEventBloc(
            MatchEventRemoteDatasource(
              baseUrl: "http://192.168.1.6:3000",
              adminId: adminId,
            ),
          ),
        ),

        // 🔹 Match Lifecycle Bloc (optional)
        BlocProvider(
          create: (_) => MatchLifecycleBloc(
            MatchLifecycleRemoteDatasource(
              baseUrl: "http://192.168.1.6:3000",
              adminId: adminId,
            ),
          ),
        ),
      ],
      child: LiveMatchPage(
        match: match,
      ),
    ),
  ),
);


                                            }
                                          },
                                    child: Text(
                                      isUpcoming
                                          ? "Start Match"
                                          : isLive
                                              ? "Enter Live Control"
                                              : "Finished",
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
