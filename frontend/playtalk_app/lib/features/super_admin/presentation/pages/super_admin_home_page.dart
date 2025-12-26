import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tournament_bloc.dart';
import '../bloc/tornament_state.dart';
import '../../domain/models/tournament_model.dart';
import 'create_tournament_page.dart';
import 'tournament_details_page.dart';

class SuperAdminHomePage extends StatelessWidget {
  const SuperAdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Super Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "College: ABC Engineering College",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateTournamentPage(),
                  ),
                );
              },
              child: const Text("Create Tournament"),
            ),

            const SizedBox(height: 24),

            const Text(
              "Tournaments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: BlocBuilder<TournamentBloc, TournamentState>(
                builder: (context, state) {
                  if (state is TournamentLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is TournamentLoaded) {
                    if (state.tournaments.isEmpty) {
                      return const Center(
                        child: Text("No tournaments created yet"),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.tournaments.length,
                      itemBuilder: (context, index) {
                        final TournamentModel t =
                            state.tournaments[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(t.name),
                            subtitle: Text("${t.sport} • ${t.mode}"),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TournamentDetailsPage(tournament: t),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  if (state is TournamentError) {
                    return Center(
                      child: Text(state.message),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
