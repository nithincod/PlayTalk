import 'package:flutter/material.dart';
import '../../domain/models/match_model.dart';

class FinishedMatchesPage extends StatelessWidget {
  final List<MatchModel> matches;

  const FinishedMatchesPage({
    super.key,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Finished Matches",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Total ${matches.length} matches completed",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return _FinishedMatchCard(match: matches[index]);
        },
      ),
    );
  }
}


class _FinishedMatchCard extends StatelessWidget {
  final MatchModel match;

  const _FinishedMatchCard({required this.match});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Sport + Status
          Row(
            children: [
              _sportIcon(match.sport),
              const SizedBox(width: 8),
              Text(
                match.sport.toUpperCase(),
                style: const TextStyle(
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              _statusChip(),
            ],
          ),

          const SizedBox(height: 16),

          // 🔹 Teams & Score
          Row(
            children: [
              _teamColumn(match.teamA, isWinner: true),
              const Spacer(),
              Column(
                children: const [
                  Text(
                    "86 - 82",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "FINAL SCORE",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _teamColumn(match.teamB),
            ],
          ),

          const SizedBox(height: 16),

          // 🔹 Venue & Time
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                match.court,
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              const Text(
                "Oct 24, 18:30",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "FINISHED",
        style: TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _teamColumn(String name, {bool isWinner = false}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              isWinner ? Colors.blueAccent : Colors.grey.shade700,
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: isWinner ? Colors.white : Colors.grey,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _sportIcon(String sport) {
    IconData icon;
    switch (sport.toLowerCase()) {
      case "basketball":
        icon = Icons.sports_basketball;
        break;
      case "football":
        icon = Icons.sports_soccer;
        break;
      case "tennis":
        icon = Icons.sports_tennis;
        break;
      case "badminton":
        icon = Icons.sports;
        break;
      case "kabaddi":
        icon = Icons.sports_mma;
        break;
      default:
        icon = Icons.sports;
    }

    return Icon(icon, color: Colors.orange);
  }
}
