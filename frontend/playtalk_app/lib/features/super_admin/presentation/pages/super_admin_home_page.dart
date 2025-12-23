import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/tournament_model.dart';
import '../bloc/tornament_state.dart';
import '../bloc/tournament_bloc.dart';
import 'create_tournament_page.dart';

class SuperAdminHomePage extends StatelessWidget {
  const SuperAdminHomePage({super.key});

  // TEMP DUMMY DATA (WILL COME FROM BACKEND LATER)
  List<TournamentModel> _dummyTournaments() {
    return [
      TournamentModel(
        id: "1",
        name: "Inter-College Badminton",
        sport: "Badminton",
        mode: "Manual",
      ),
      TournamentModel(
        id: "2",
        name: "Kabaddi League",
        sport: "Kabaddi",
        mode: "Automatic",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // final tournaments = _dummyTournaments();

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
        return const Center(child: CircularProgressIndicator());
      } else if (state is TournamentLoaded) {
        return ListView.builder(
          itemCount: state.tournaments.length,
          itemBuilder: (context, index) {
            final t = state.tournaments[index];
            return Card(
              child: ListTile(
                title: Text(t.name),
                subtitle: Text("${t.sport} • ${t.mode}"),
              ),
            );
          },
        );
      } else if (state is TournamentError) {
        return Center(child: Text(state.message));
      }
      return const SizedBox();
    },
  ),
            )

          ],
        ),
      ),
    );
  }
}
