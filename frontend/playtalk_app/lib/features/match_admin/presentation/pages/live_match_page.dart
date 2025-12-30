import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/match_event_bloc.dart';
import '../bloc/match_event_event.dart';
import '../bloc/match_event_state.dart';
import '../../domain/models/match_model.dart';

class LiveMatchPage extends StatelessWidget {
  final MatchModel match;

  const LiveMatchPage({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${match.name} (LIVE)"),
      ),
      body: BlocListener<MatchEventBloc, MatchEventState>(
        listener: (context, state) {
          if (state is MatchEventFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if(state is MatchEventSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Event submitted successfully")),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _matchHeader(match),
              const SizedBox(height: 16),
              _scoreSection(match),
              const SizedBox(height: 24),
              _actionButtons(context, match),
              const SizedBox(height: 24),
              _eventTimeline(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 HEADER
  Widget _matchHeader(MatchModel match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${match.teamA} vs ${match.teamB}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text("Sport: ${match.matchType}"),
        const Chip(
          label: Text("LIVE", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      ],
    );
  }

  // 🔹 SCORE (READ-ONLY)
  Widget _scoreSection(MatchModel match) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: const Text(
        "Score will be derived from events",
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  // 🔹 ACTION BUTTONS (SPORT AWARE)
  Widget _actionButtons(BuildContext context, MatchModel match) {
    switch (match.sport.toLowerCase()) {
      case "badminton":
        return _badmintonButtons(context, match);

      case "kabaddi":
        return _kabaddiButtons(context, match);

      default:
        return const Text("Unsupported sport");
    }
  }

  // 🏸 BADMINTON / TT
  Widget _badmintonButtons(BuildContext context, MatchModel match) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _sendEvent(
                  context,
                  match,
                  type: "POINT",
                  team: match.teamA,
                  value: 1,
                ),
                child: Text("${match.teamA} +1"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _sendEvent(
                  context,
                  match,
                  type: "POINT",
                  team: match.teamB,
                  value: 1,
                ),
                child: Text("${match.teamB} +1"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _sendEvent(
            context,
            match,
            type: "END_SET",
            team: "",
            value: 0,
          ),
          child: const Text("End Set"),
        ),
      ],
    );
  }

  // 🤼 KABADDI
  Widget _kabaddiButtons(BuildContext context, MatchModel match) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _sendEvent(
            context,
            match,
            type: "RAID_POINT",
            team: "A",
            value: 2,
          ),
          child: const Text("Team A Raid +2"),
        ),
        ElevatedButton(
          onPressed: () => _sendEvent(
            context,
            match,
            type: "RAID_POINT",
            team: "B",
            value: 1,
          ),
          child: const Text("Team B Raid +1"),
        ),
      ],
    );
  }

  // 🔹 EVENT SENDER
  void _sendEvent(
    BuildContext context,
    MatchModel match, {
    required String type,
    required String team,
    required int value,
  }) {
    context.read<MatchEventBloc>().add(
          SubmitMatchEvent(
            tournamentId: match.tournamentId,
            matchId: match.matchId,
            event: {
              "type": type,
              "team": team,
              "value": value,
              "meta": {},
              "timestamp": DateTime.now().millisecondsSinceEpoch,
            },
          ),
        );
  }

  // 🔹 TIMELINE (NEXT PHASE REAL-TIME)
  Widget _eventTimeline() {
    return const Expanded(
      child: Center(
        child: Text(
          "Event timeline will appear here",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
