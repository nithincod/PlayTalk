import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/match_admin/domain/models/match_admin_model.dart';

import '../bloc/live_match_bloc.dart';
import '../bloc/live_match_event.dart';
import '../bloc/live_match_state.dart';

import '../bloc/match_event_bloc.dart';
import '../bloc/match_event_event.dart';
import '../bloc/match_event_state.dart';

class LiveMatchPage extends StatelessWidget {
  final MatchAdminModel match;

  const LiveMatchPage({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 START REAL-TIME LISTENING
    context.read<LiveMatchBloc>().add(
          StartListeningMatch(
            collegeId: match.collegeId,
            tournamentId: match.tournamentId,
            matchId: match.matchId,
          ),
        );

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

          if (state is MatchEventSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Event submitted successfully"),
              ),
            );
          }
        },
        child: BlocBuilder<LiveMatchBloc, LiveMatchState>(
          builder: (context, state) {
            if (state is LiveMatchLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LiveMatchUpdated) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _matchHeader(match),
                    const SizedBox(height: 16),
                    _scoreSection(state.score),
                    const SizedBox(height: 24),
                    _actionButtons(context, match),
                    const SizedBox(height: 24),
                    _eventTimeline(state.events),
                  ],
                ),
              );
            }

            return const Center(
              child: Text("Failed to load match"),
            );
          },
        ),
      ),
    );
  }

  // 🔹 HEADER
  Widget _matchHeader(MatchAdminModel match) {
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
        Text("Sport: ${match.sport}"),
        const SizedBox(height: 6),
        const Chip(
          label: Text(
            "LIVE",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      ],
    );
  }

  // 🔹 LIVE SCORE
  Widget _scoreSection(Map<String, dynamic> score) {
  final currentSet = score['currentSet'] ?? {};

  final a = currentSet['A'] ?? 0;
  final b = currentSet['B'] ?? 0;

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey.shade200,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Set: $a - $b",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Sets: ${score['setsA'] ?? 0} - ${score['setsB'] ?? 0}",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}


  // 🔹 ACTION BUTTONS (SPORT AWARE)
  Widget _actionButtons(BuildContext context, MatchAdminModel match) {
    switch (match.sport.toLowerCase()) {
      case "badminton":
        return _badmintonButtons(context, match);

      case "kabaddi":
        return _kabaddiButtons(context, match);

      default:
        return const Text("Unsupported sport");
    }
  }

  // 🏸 BADMINTON
  Widget _badmintonButtons(BuildContext context, MatchAdminModel match) {
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
  Widget _kabaddiButtons(BuildContext context, MatchAdminModel match) {
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

  // 🔹 SEND EVENT TO BACKEND
  void _sendEvent(
    BuildContext context,
    MatchAdminModel match, {
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
            },
          ),
        );
  }

  // 🔹 EVENT TIMELINE
  Widget _eventTimeline(List<dynamic> events) {
    if (events.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "No events yet",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final e = events[index];
          return ListTile(
            dense: true,
            title: Text("${e['type']} - ${e['team']}"),
            trailing: Text("+${e['value']}"),
          );
        },
      ),
    );
  }
}
