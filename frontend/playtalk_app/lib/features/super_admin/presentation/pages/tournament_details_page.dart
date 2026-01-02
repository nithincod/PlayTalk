import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/assign_match_page.dart';

import '../../data/datasources/assign_match_admin_remote_datasource.dart';
import '../../domain/models/tournament_model.dart';
import '../../domain/models/match_model.dart';
import '../bloc/assign_match_admin_bloc.dart';
import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';
import '../bloc/match_state.dart';
import '../../data/datasources/match_remote_datasource.dart';
import 'create_match_page.dart';

class TournamentDetailsPage extends StatelessWidget {
  final TournamentModel tournament;

  const TournamentDetailsPage({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    final matchDatasource = MatchRemoteDatasource(
      baseUrl: "http://192.168.1.2:3000",
      adminId: "-Oh19e8DauETQEhQxB5G", // TODO: from auth
    );

    return BlocProvider(
      create: (_) => MatchBloc(matchDatasource)
        ..add(LoadMatches(tournament.tournamentId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Tournament Details"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tournament Info
                  Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Sport: ${tournament.sport}"),
                  Text("Mode: ${tournament.mode}"),

                  const SizedBox(height: 24),

                  const Text(
                    "Matches",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // MATCH LIST
                  Expanded(
                    child: BlocBuilder<MatchBloc, MatchState>(
                      builder: (context, state) {
                        if (state is MatchLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is MatchLoaded) {
                          if (state.matches.isEmpty) {
                            return const Center(
                              child: Text("No matches created yet"),
                            );
                          }

                          return ListView.builder(
                            itemCount: state.matches.length,
                            itemBuilder: (context, index) {
                              final MatchModel m = state.matches[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(m.name),
                                  subtitle: Text(
                                    "${m.teamA} vs ${m.teamB}\n${m.matchType} • ${m.court}",
                                  ),
                                  isThreeLine: true,

                                  // 🔹 ASSIGN MATCH ADMIN ICON
                                  trailing: IconButton(
                                    icon: const Icon(Icons.person_add),
                                    onPressed: () {
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => AssignMatchAdminBloc(
        AssignMatchAdminRemoteDatasource(
          baseUrl: "http://192.168.1.2:3000",
          superAdminId: "-Oh19e8DauETQEhQxB5G",
        ),
      ),
      child: AssignMatchAdminPage(
        tournamentId: tournament.tournamentId,
        matchId: m.matchId,
        matchName: m.name,
      ),
    ),
  ),
);

},

                                  ),
                                ),
                              );
                            },
                          );
                        }

                        if (state is MatchError) {
                          return Center(
                            child: Text(state.message),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),

                  // CREATE MATCH BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<MatchBloc>(),
                              child: CreateMatchPage(
                                tournamentId: tournament.tournamentId,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text("Create Match"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
