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

// class LiveMatchPage extends StatefulWidget {
//   final MatchAdminModel match;

//   const LiveMatchPage({
//     super.key,
//     required this.match,
//   });

//   @override
//   State<LiveMatchPage> createState() => _LiveMatchPageState();
// }

// class _LiveMatchPageState extends State<LiveMatchPage> {
//   @override
//   void initState() {
//     super.initState();

//     // 🔥 Start Firebase live listening (ONLY ONCE)
//     context.read<LiveMatchBloc>().add(
//           StartListeningMatch(
//             collegeId: widget.match.collegeId,
//             tournamentId: widget.match.tournamentId,
//             matchId: widget.match.matchId,
//           ),
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.match.name),
//       ),
//       body: MultiBlocListener(
//         listeners: [
//           BlocListener<MatchEventBloc, MatchEventState>(
//             listener: (context, state) {
//               if (state is MatchEventFailure) {
//                 ScaffoldMessenger.of(context)
//                     .showSnackBar(SnackBar(content: Text(state.message)));
//               }
//             },
//           ),
//           BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
//             listener: (context, state) {
//               if (state is MatchLifecycleSuccess) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Match finished successfully")),
//                 );
//               }
//               if (state is MatchLifecycleFailure) {
//                 ScaffoldMessenger.of(context)
//                     .showSnackBar(SnackBar(content: Text(state.message)));
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<LiveMatchBloc, LiveMatchState>(
//           builder: (context, state) {
//             if (state is LiveMatchLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (state is LiveMatchUpdated) {
//               final score = state.score;
//               final winner = score['winner']; // can be null
//               final isFinished = widget.match.status == "finished";

//               return Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _matchHeader(widget.match, isFinished),
//                     const SizedBox(height: 16),

//                     // 🏆 WINNER DISPLAY (does NOT finish match)
//                     if (winner != null) _winnerBanner(winner),

//                     _scoreSection(score),
//                     const SizedBox(height: 20),

//                     // 🔴 FINISH MATCH BUTTON (manual)
//                     if (winner != null && !isFinished)
//                       _finishMatchButton(context),

//                     const SizedBox(height: 20),

//                     _actionButtons(
//                       context,
//                       widget.match,
//                       isFinished,
//                     ),

//                     const SizedBox(height: 20),
//                     _eventTimeline(state.events),
//                   ],
//                 ),
//               );
//             }

//             return const Center(child: Text("Failed to load match"));
//           },
//         ),
//       ),
//     );
//   }

//   // 🔹 HEADER
//   Widget _matchHeader(MatchAdminModel match, bool isFinished) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "${match.teamA} vs ${match.teamB}",
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         Text("Sport: ${match.sport}"),
//         const SizedBox(height: 6),
//       ],
//     );
//   }

//   // 🏆 WINNER BANNER
//   Widget _winnerBanner(String winner) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.green.shade600,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         "🏆 Winner: $winner",
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   // 🔹 SCORE
//   Widget _scoreSection(Map<String, dynamic> score) {
//     final currentSet = score['currentSet'] ?? {};
//     final a = currentSet['A'] ?? 0;
//     final b = currentSet['B'] ?? 0;

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.grey.shade200,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Current Set: $a - $b",
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Sets: ${score['setsA'] ?? 0} - ${score['setsB'] ?? 0}",
//             style: const TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   // 🔴 FINISH MATCH BUTTON
//  Widget _finishMatchButton(BuildContext context) {
//   return BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
//     listener: (context, state) {
//       if (state is MatchLifecycleSuccess) {
//         Navigator.pop(context); // 🔥 GO BACK
//       }
//     },
//     child: ElevatedButton.icon(
//       style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//       icon: const Icon(Icons.stop),
//       label: const Text("Finish Match"),
//       onPressed: () {
//         context.read<MatchLifecycleBloc>().add(
//               EndMatchPressed(
//                 widget.match.matchId,
//                 widget.match.tournamentId,
//               ),
//             );
//       },
//     ),
//   );
// }



//   // 🔹 ACTION BUTTONS
//   Widget _actionButtons(
//     BuildContext context,
//     MatchAdminModel match,
//     bool isFinished,
//   ) {
//     if (isFinished) {
//       return const Text(
//         "Match finished. Scoring locked.",
//         style: TextStyle(color: Colors.grey),
//       );
//     }

//     switch (match.sport.toLowerCase()) {
//       case "badminton":
//         return _badmintonButtons(context, match);
//       case "kabaddi":
//         return _kabaddiButtons(context, match);
//       default:
//         return const Text("Unsupported sport");
//     }
//   }

//   // 🏸 BADMINTON BUTTONS
//   Widget _badmintonButtons(BuildContext context, MatchAdminModel match) {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () => _sendEvent(
//               context,
//               match,
//               type: "POINT",
//               team: match.teamA,
//               value: 1,
//             ),
//             child: Text("${match.teamA} +1"),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () => _sendEvent(
//               context,
//               match,
//               type: "POINT",
//               team: match.teamB,
//               value: 1,
//             ),
//             child: Text("${match.teamB} +1"),
//           ),
//         ),
//       ],
//     );
//   }

//   // 🤼 KABADDI BUTTONS
//   Widget _kabaddiButtons(BuildContext context, MatchAdminModel match) {
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () => _sendEvent(
//             context,
//             match,
//             type: "RAID_POINT",
//             team: "A",
//             value: 2,
//           ),
//           child: const Text("Team A Raid +2"),
//         ),
//         ElevatedButton(
//           onPressed: () => _sendEvent(
//             context,
//             match,
//             type: "RAID_POINT",
//             team: "B",
//             value: 1,
//           ),
//           child: const Text("Team B Raid +1"),
//         ),
//       ],
//     );
//   }

//   // 🔹 SEND EVENT
//   void _sendEvent(
//     BuildContext context,
//     MatchAdminModel match, {
//     required String type,
//     required String team,
//     required int value,
//   }) {
//     context.read<MatchEventBloc>().add(
//           SubmitMatchEvent(
//             tournamentId: match.tournamentId,
//             matchId: match.matchId,
//             event: {
//               "type": type,
//               "team": team,
//               "value": value,
//               "meta": {},
//             },
//           ),
//         );
//   }

//   // 🔹 EVENTS
//   Widget _eventTimeline(List<dynamic> events) {
//     if (events.isEmpty) {
//       return const Expanded(child: Center(child: Text("No events yet")));
//     }

//     return Expanded(
//       child: ListView.builder(
//         itemCount: events.length,
//         itemBuilder: (context, index) {
//           final e = events[index];
//           return ListTile(
//             dense: true,
//             title: Text("${e['type']} - ${e['team']}"),
//             trailing: Text("+${e['value']}"),
//           );
//         },
//       ),
//     );
//   }
// }


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
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.stop, color: Colors.red),
            label: const Text("End Set",
                style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<MatchLifecycleBloc>().add(
                    EndMatchPressed(
                      widget.match.matchId,
                      widget.match.tournamentId,
                    ),
                  );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  Widget _matchFeed(List<dynamic> events) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Match Feed",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (_, i) {
                final e = events[i];
                return ListTile(
                  leading: const Icon(Icons.circle, size: 8),
                  title: Text("${e['type']} • ${e['team']}",
                      style: const TextStyle(color: Colors.white)),
                  trailing: Text("+${e['value']}"),
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
