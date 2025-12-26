import 'package:flutter/material.dart';
import '../../../super_admin/domain/models/match_model.dart';

class MatchAdminHomePage extends StatelessWidget {
  const MatchAdminHomePage({super.key});

  // TEMP DUMMY MATCHES
  List<MatchModel> _assignedMatches() {
    return [
      MatchModel(
        id: "1",
        name: "Quarter Final 1",
        teamA: "Team A",
        teamB: "Team B",
        court: "Court 1",
        matchType: "Singles",
      ),
      MatchModel(
        id: "2",
        name: "Semi Final",
        teamA: "Team C",
        teamB: "Team D",
        court: "Court 2",
        matchType: "Doubles",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final matches = _assignedMatches();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Match Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assigned Matches",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

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
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Next phase: open Live Match Control
                        },
                        child: const Text("Enter"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
