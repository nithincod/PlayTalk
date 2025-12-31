import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/match_admin/domain/models/match_admin_model.dart';

import '../bloc/live_match_bloc.dart';
import '../bloc/live_match_event.dart';
import '../bloc/live_match_state.dart';

import '../bloc/match_event_bloc.dart';
import '../bloc/match_event_event.dart';
import '../bloc/match_event_state.dart';

import '../bloc/match_lifecycle_bloc.dart';
import '../bloc/match_lifecycle_event.dart';
import '../bloc/match_lifecycle_state.dart';

class LiveMatchPage extends StatefulWidget {
  final MatchAdminModel match;

  const LiveMatchPage({
    super.key,
    required this.match,
  });

  @override
  State<LiveMatchPage> createState() => _LiveMatchPageState();
}

class _LiveMatchPageState extends State<LiveMatchPage> {
  @override
  void initState() {
    super.initState();

    // 🔥 Start Firebase live listening (ONLY ONCE)
    context.read<LiveMatchBloc>().add(
          StartListeningMatch(
            collegeId: widget.match.collegeId,
            tournamentId: widget.match.tournamentId,
            matchId: widget.match.matchId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.name),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MatchEventBloc, MatchEventState>(
            listener: (context, state) {
              if (state is MatchEventFailure) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
            listener: (context, state) {
              if (state is MatchLifecycleSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Match finished successfully")),
                );
              }
              if (state is MatchLifecycleFailure) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: BlocBuilder<LiveMatchBloc, LiveMatchState>(
          builder: (context, state) {
            if (state is LiveMatchLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LiveMatchUpdated) {
              final score = state.score;
              final winner = score['winner']; // can be null
              final isFinished = widget.match.status == "finished";

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _matchHeader(widget.match, isFinished),
                    const SizedBox(height: 16),

                    // 🏆 WINNER DISPLAY (does NOT finish match)
                    if (winner != null) _winnerBanner(winner),

                    _scoreSection(score),
                    const SizedBox(height: 20),

                    // 🔴 FINISH MATCH BUTTON (manual)
                    if (winner != null && !isFinished)
                      _finishMatchButton(context),

                    const SizedBox(height: 20),

                    _actionButtons(
                      context,
                      widget.match,
                      isFinished,
                    ),

                    const SizedBox(height: 20),
                    _eventTimeline(state.events),
                  ],
                ),
              );
            }

            return const Center(child: Text("Failed to load match"));
          },
        ),
      ),
    );
  }

  // 🔹 HEADER
  Widget _matchHeader(MatchAdminModel match, bool isFinished) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${match.teamA} vs ${match.teamB}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text("Sport: ${match.sport}"),
        const SizedBox(height: 6),
      ],
    );
  }

  // 🏆 WINNER BANNER
  Widget _winnerBanner(String winner) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "🏆 Winner: $winner",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 🔹 SCORE
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

  // 🔴 FINISH MATCH BUTTON
 Widget _finishMatchButton(BuildContext context) {
  return BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
    listener: (context, state) {
      if (state is MatchLifecycleSuccess) {
        Navigator.pop(context); // 🔥 GO BACK
      }
    },
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      icon: const Icon(Icons.stop),
      label: const Text("Finish Match"),
      onPressed: () {
        context.read<MatchLifecycleBloc>().add(
              EndMatchPressed(
                widget.match.matchId,
                widget.match.tournamentId,
              ),
            );
      },
    ),
  );
}



  // 🔹 ACTION BUTTONS
  Widget _actionButtons(
    BuildContext context,
    MatchAdminModel match,
    bool isFinished,
  ) {
    if (isFinished) {
      return const Text(
        "Match finished. Scoring locked.",
        style: TextStyle(color: Colors.grey),
      );
    }

    switch (match.sport.toLowerCase()) {
      case "badminton":
        return _badmintonButtons(context, match);
      case "kabaddi":
        return _kabaddiButtons(context, match);
      default:
        return const Text("Unsupported sport");
    }
  }

  // 🏸 BADMINTON BUTTONS
  Widget _badmintonButtons(BuildContext context, MatchAdminModel match) {
    return Row(
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
    );
  }

  // 🤼 KABADDI BUTTONS
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

  // 🔹 SEND EVENT
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

  // 🔹 EVENTS
  Widget _eventTimeline(List<dynamic> events) {
    if (events.isEmpty) {
      return const Expanded(child: Center(child: Text("No events yet")));
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
