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
      backgroundColor: const Color(0xFF0F1424),
      appBar: _liveAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
            listener: (context, state) {
              if (state is MatchLifecycleSuccess) {
                Navigator.pop(context);
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
              final winner = score['winner'];

              return winner != null
                  ? _winnerScreen(score, winner)
                  : _liveControlUI(score, state.events);
            }

            return const Center(child: Text("Unable to load match"));
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  PreferredSizeWidget _liveAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F1424),
      elevation: 0,
      leading: const BackButton(color: Colors.white,),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("EIFER TOURNAMENT",
              style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 249, 248, 248))),
          Text(widget.match.sport.toUpperCase(),
              style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text("LIVE",
              style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  Widget _liveControlUI(
    Map<String, dynamic> score,
    List<dynamic> events,
  ) {
    final currentSet = score['currentSet'] ?? {};
    final a = currentSet['A'] ?? 0;
    final b = currentSet['B'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _setTimer(score),
          const SizedBox(height: 16),

          _scoreCards(a, b),
          const SizedBox(height: 24),

          _scoringControls(),
          const SizedBox(height: 16),

          _actionChips(),
          const SizedBox(height: 16),

          _timeoutAndEndSet(),
          const SizedBox(height: 16),

          _matchFeed(events),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  Widget _setTimer(Map<String, dynamic> score) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2438),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          "Set ${score['currentSetNo'] ?? 1} • ${score['time'] ?? '00:00'}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  Widget _scoreCards(int a, int b) {
    return Row(
      children: [
        _teamScoreCard(widget.match.teamA, a, active: true),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text("VS", style: TextStyle(color: Colors.grey)),
        ),
        _teamScoreCard(widget.match.teamB, b),
      ],
    );
  }

  Widget _teamScoreCard(String team, int score, {bool active = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2438),
          borderRadius: BorderRadius.circular(20),
          border: active
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Text(team,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              score.toString(),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  Widget _scoringControls() {
    return Row(
      children: [
        Expanded(
          child: _scoreButton(widget.match.teamA),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _scoreButton(widget.match.teamB),
        ),
      ],
    );
  }

  Widget _scoreButton(String team) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D5BFF),
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      onPressed: () => _sendPoint(team),
      child: Text("+1\n$team",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18,color: Colors.white),)
    );
  }

  // ─────────────────────────────────────
  Widget _actionChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _ActionChip("Service Fault"),
          _ActionChip("Smash Winner"),
          _ActionChip("Unforced Err"),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  Widget _timeoutAndEndSet() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.pause, color: Colors.amber),
            label: const Text("Timeout",
                style: TextStyle(color: Colors.amber)),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  Widget _matchFeed(List<dynamic> events) {
  final sortedEvents = List<dynamic>.from(events)
    ..sort((a, b) {
      final aTs = int.tryParse((a["timestamp"] ?? 0).toString()) ?? 0;
      final bTs = int.tryParse((b["timestamp"] ?? 0).toString()) ?? 0;
      return bTs.compareTo(aTs); // latest first
    });

  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Match Feed",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: sortedEvents.length,
            itemBuilder: (_, i) {
              final e = sortedEvents[i] as Map<String, dynamic>;

              final commentary = e["commentary"] is Map
                  ? Map<String, dynamic>.from(e["commentary"])
                  : null;

              final commentaryText =
                  (commentary?["text"] ?? "").toString().trim();

              final isImportant = commentary?["important"] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isImportant
                      ? Colors.amber.withOpacity(0.10)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isImportant
                        ? Colors.amber.withOpacity(0.35)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        isImportant ? Icons.mic : Icons.circle,
                        size: isImportant ? 16 : 8,
                        color: isImportant ? Colors.amber : Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${e['type']} • ${e['team']}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            commentaryText.isNotEmpty
                                ? commentaryText
                                : "${e['type']} • ${e['team']}",
                            style: TextStyle(
                              color: isImportant ? Colors.amber : Colors.white,
                              fontSize: 14,
                              fontWeight: isImportant
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "+${e['value'] ?? 0}",
                      style: TextStyle(
                        color: isImportant ? Colors.amber : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

  // ─────────────────────────────────────
  Widget _winnerScreen(Map<String, dynamic> score, String winner) {
    // Automatically end the match when winner is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchLifecycleBloc>().add(
            EndMatchPressed(
              widget.match.matchId,
              widget.match.tournamentId,
            ),
          );
    });
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events,
              size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            winner,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          const SizedBox(height: 8),
          const Text("Winner",
              style: TextStyle(color: Colors.green)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Return to Home"),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  void _sendPoint(String team) {
    context.read<MatchEventBloc>().add(
          SubmitMatchEvent(
            tournamentId: widget.match.tournamentId,
            matchId: widget.match.matchId,
            event: {
              "type": "POINT",
              "team": team,
              "value": 1,
            },
          ),
        );
  }
}

// ─────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final String label;
  const _ActionChip(this.label);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      child: Text(label),
    );
  }
}
