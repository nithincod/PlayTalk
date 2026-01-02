import 'package:flutter/material.dart';
import '../../domain/models/match_model.dart';

class OngoingMatchesPage extends StatelessWidget {
  final List<MatchModel> matches;

  const OngoingMatchesPage({
    super.key,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2438),
        elevation: 0,
        title: const Text("Ongoing Matches"),
      ),
      body: matches.isEmpty
          ? const Center(
              child: Text(
                "No live matches",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return _LiveMatchCard(match: match);
              },
            ),
    );
  }
}
class _LiveMatchCard extends StatelessWidget {
  final MatchModel match;

  const _LiveMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2438),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _sportIcon(match.sport),
              const SizedBox(width: 8),
              Text(
                "${match.sport.toUpperCase()} • ${match.matchType}",
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              _liveBadge(),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _team(match.teamA),
              const Text(
                "VS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _team(match.teamB),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 6),
              Text(
                match.court,
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // MATCH CENTER NAVIGATION
                },
                child: const Text("MATCH CENTER →"),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _team(String name) {
    return Column(
      children: [
        const CircleAvatar(radius: 22),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "LIVE",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _sportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case "basketball":
        return const Icon(Icons.sports_basketball, color: Colors.orange);
      case "volleyball":
        return const Icon(Icons.sports_volleyball, color: Colors.blue);
      case "badminton":
        return const Icon(Icons.sports_tennis, color: Colors.green);
      case "kabaddi":
        return const Icon(Icons.sports_mma, color: Colors.red);
      default:
        return const Icon(Icons.sports, color: Colors.grey);
    }
  }
}
