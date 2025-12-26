import 'package:flutter/material.dart';
import '../../domain/models/tournament_model.dart';
import '../../domain/models/match_model.dart';
import 'create_match_page.dart';

class TournamentDetailsPage extends StatelessWidget {
  final TournamentModel tournament;

  const TournamentDetailsPage({
    super.key,
    required this.tournament,
  });

  // TEMP DUMMY MATCHES
  List<MatchModel> _dummyMatches() {
    return [
      MatchModel(
        id: "1",
        name: "Match 1",
        teamA: "Team A",
        teamB: "Team B",
        court: "Court 1",
        matchType: "Singles",
      ),
      MatchModel(
        id: "2",
        name: "Match 2",
        teamA: "Team C",
        teamB: "Team D",
        court: "Court 2",
        matchType: "Doubles",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final matches = _dummyMatches();

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

            // Matches Header
            const Text(
              "Matches",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Match List
            Expanded(
              child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final m = matches[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(m.name),
                      subtitle: Text(
                        "${m.teamA} vs ${m.teamB}\n${m.matchType} • ${m.court}",
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Next phase: match details / live control
                      },
                    ),
                  );
                },
              ),
            ),

            // Create Match Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateMatchPage(),
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
  }
}
