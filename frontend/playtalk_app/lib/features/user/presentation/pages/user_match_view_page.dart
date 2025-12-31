import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../match_admin/presentation/bloc/live_match_bloc.dart';
import '../../../match_admin/presentation/bloc/live_match_event.dart';
import '../../../match_admin/presentation/bloc/live_match_state.dart';

class UserMatchViewPage extends StatefulWidget {
  final String collegeId;
  final String tournamentId;
  final String matchId;
  final String matchName;

  const UserMatchViewPage({
    super.key,
    required this.collegeId,
    required this.tournamentId,
    required this.matchId,
    required this.matchName,
  });

  @override
  State<UserMatchViewPage> createState() => _UserMatchViewPageState();
}

class _UserMatchViewPageState extends State<UserMatchViewPage> {
  @override
  void initState() {
    super.initState();

    context.read<LiveMatchBloc>().add(
          StartListeningMatch(
            collegeId: widget.collegeId,
            tournamentId: widget.tournamentId,
            matchId: widget.matchId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.matchName)),
      body: BlocBuilder<LiveMatchBloc, LiveMatchState>(
        builder: (context, state) {
          if (state is LiveMatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LiveMatchUpdated) {
            final score = state.score;
            final currentSet = score['currentSet'] ?? {};
            final winner = score['winner'];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (winner != null)
                    _winnerBanner(winner),

                  Text(
                    "Current Set: ${currentSet['A'] ?? 0} - ${currentSet['B'] ?? 0}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Sets: ${score['setsA'] ?? 0} - ${score['setsB'] ?? 0}",
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Events",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: state.events.length,
                      itemBuilder: (context, index) {
                        final e = state.events[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            "${e['type']} - ${e['team']}",
                          ),
                          trailing: Text("+${e['value']}"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Failed to load match"));
        },
      ),
    );
  }

  Widget _winnerBanner(String winner) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
}
