import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/user/presentation/bloc/user_live_bloc.dart';
import 'package:playtalk_app/features/user/presentation/pages/user_live_stream_page.dart';

import '../../domain/models/user_match_model.dart';

import '../bloc/user_live_match_event.dart';
import '../bloc/user_live_match_state.dart';

class UserMatchDetailsPage extends StatefulWidget {
  final UserMatchModel match;

  const UserMatchDetailsPage({
    super.key,
    required this.match,
  });

  @override
  State<UserMatchDetailsPage> createState() => _UserMatchDetailsPageState();
}

class _UserMatchDetailsPageState extends State<UserMatchDetailsPage> {
  @override
  void initState() {
    super.initState();

    // Start realtime listener after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserLiveMatchBloc>().add(
            WatchUserLiveMatch(
              collegeId: widget.match.collegeId,
              tournamentId: widget.match.tournamentId,
              matchId: widget.match.matchId,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseMatch = widget.match;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        title: const Text(
          "Match Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<UserLiveMatchBloc, UserLiveMatchState>(
        builder: (context, state) {
          if (state.loading && state.match == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null && state.match == null) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final liveData = state.match ?? {};
          debugPrint("LIVE DATA: $liveData");

          // ─────────────────────────────────────────────
          // BASIC FIELDS (prefer live data, fallback to passed match)
          // ─────────────────────────────────────────────
          final String teamA = (liveData["teamA"] ?? baseMatch.teamA).toString();
          final String teamB = (liveData["teamB"] ?? baseMatch.teamB).toString();
          final String sport = (liveData["sport"] ?? baseMatch.sport).toString();
          final String court = (liveData["court"] ?? baseMatch.court).toString();
          final String name = (liveData["name"] ?? baseMatch.name).toString();
          final String status =
              (liveData["status"] ?? baseMatch.status).toString().toLowerCase();

          final stream = liveData["stream"] is Map
    ? Map<String, dynamic>.from(liveData["stream"])
    : <String, dynamic>{
        "isStreaming": baseMatch.isStreaming,
        "streamKey": baseMatch.streamKey,
        "hlsUrl": baseMatch.hlsUrl,
      };

final bool isStreaming = stream["isStreaming"] == true;
final String hlsUrl = (stream["hlsUrl"] ?? baseMatch.hlsUrl).toString();    

          // ─────────────────────────────────────────────
          // SCORE PARSING (supports multiple backend formats)
          // ─────────────────────────────────────────────
          int _toInt(dynamic value) {
            return int.tryParse((value ?? 0).toString()) ?? 0;
          }

          int teamAScore = baseMatch.teamAScore;
          int teamBScore = baseMatch.teamBScore;

          final score = liveData["score"];

          if (score is Map) {
            final scoreMap = Map<String, dynamic>.from(score);

            // ✅ BADMINTON / SET-BASED FORMAT
            if (scoreMap["currentSet"] is Map) {
              final currentSet =
                  Map<String, dynamic>.from(scoreMap["currentSet"]);

              teamAScore = _toInt(currentSet["A"]);
              teamBScore = _toInt(currentSet["B"]);
            }

            // ✅ Generic flat score format
            else {
              teamAScore = _toInt(
                scoreMap["teamA"] ??
                    scoreMap["teamAScore"] ??
                    scoreMap["a"] ??
                    scoreMap["scoreA"],
              );

              teamBScore = _toInt(
                scoreMap["teamB"] ??
                    scoreMap["teamBScore"] ??
                    scoreMap["b"] ??
                    scoreMap["scoreB"],
              );
            }
          }

          // ✅ Top-level fallback
          teamAScore = _toInt(
            liveData["teamAScore"] ??
                liveData["scoreA"] ??
                liveData["team_a_score"] ??
                teamAScore,
          );

          teamBScore = _toInt(
            liveData["teamBScore"] ??
                liveData["scoreB"] ??
                liveData["team_b_score"] ??
                teamBScore,
          );

          // Optional: set-based info for badminton
          int setsA = 0;
          int setsB = 0;

          if (score is Map) {
            final scoreMap = Map<String, dynamic>.from(score);
            setsA = _toInt(scoreMap["setsA"]);
            setsB = _toInt(scoreMap["setsB"]);
          }

          // ─────────────────────────────────────────────
          // EVENTS PARSING
          // ─────────────────────────────────────────────
          List<Map<String, dynamic>> events = [];
          final rawEvents = liveData["events"];

          if (rawEvents is Map) {
            final map = Map<String, dynamic>.from(rawEvents);

            events = map.entries.map((entry) {
              final val = Map<String, dynamic>.from(entry.value);
              return {
                "eventId": entry.key,
                ...val,
              };
            }).toList();

            // latest first
            events.sort(
              (a, b) => _toInt(b["timestamp"]).compareTo(_toInt(a["timestamp"])),
            );
          } else if (rawEvents is List) {
            events = rawEvents
                .where((e) => e != null)
                .map((e) => Map<String, dynamic>.from(e))
                .toList();

            events.sort(
              (a, b) => _toInt(b["timestamp"]).compareTo(_toInt(a["timestamp"])),
            );
          }

          // ✅ Fallback: derive score from events if score missing
          if (events.isNotEmpty && teamAScore == 0 && teamBScore == 0) {
            final teamANormalized = teamA.trim().toLowerCase();
            final teamBNormalized = teamB.trim().toLowerCase();

            for (final e in events) {
              final type = (e["type"] ?? "").toString().toLowerCase();
              final eventTeam =
                  (e["team"] ?? "").toString().trim().toLowerCase();
              final value = _toInt(e["value"]);

              if (type == "point") {
                final points = value == 0 ? 1 : value;

                if (eventTeam == teamANormalized) {
                  teamAScore += points;
                } else if (eventTeam == teamBNormalized) {
                  teamBScore += points;
                }
              }
            }
          }

          final bool isLive = status == "live";
          final bool isUpcoming = status == "upcoming";
          final bool isFinished = status == "finished";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _scoreCard(
  name: name,
  teamA: teamA,
  teamB: teamB,
  teamAScore: teamAScore,
  teamBScore: teamBScore,
  sport: sport,
  court: court,
  status: status,
  setsA: setsA,
  setsB: setsB,
),
const SizedBox(height: 16),

if (isStreaming && hlsUrl.isNotEmpty) ...[
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserLiveStreamPage(
              hlsUrl: hlsUrl,
              title: "$teamA vs $teamB",
            ),
          ),
        );
      },
      icon: const Icon(Icons.play_circle_fill),
      label: const Text("Watch Live Stream"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  ),
  const SizedBox(height: 16),
],

const SizedBox(height: 8),

                // Status helper text
                if (isUpcoming)
                  _infoBanner(
                    icon: Icons.schedule,
                    text: "This match has not started yet.",
                    color: Colors.orange,
                  ),

                if (isFinished)
                  _infoBanner(
                    icon: Icons.emoji_events,
                    text: "Match finished. Final result shown above.",
                    color: Colors.grey,
                  ),

                if (isLive || events.isNotEmpty) ...[
                  const Text(
                    "Match Timeline",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _timeline(events, teamA, teamB),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SCORE CARD
  // ─────────────────────────────────────────────
  Widget _scoreCard({
    required String name,
    required String teamA,
    required String teamB,
    required int teamAScore,
    required int teamBScore,
    required String sport,
    required String court,
    required String status,
    required int setsA,
    required int setsB,
  }) {
    final Color statusColor = status == "live"
        ? Colors.green
        : status == "upcoming"
            ? Colors.orange
            : Colors.grey;

    final String statusText = status == "live"
        ? "LIVE"
        : status == "upcoming"
            ? "UPCOMING"
            : "FINISHED";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Teams + score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _teamColumn(teamA),
              Text(
                "$teamAScore : $teamBScore",
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              _teamColumn(teamB),
            ],
          ),

          const SizedBox(height: 18),

          // Optional sets row (very useful for badminton)
          if (sport.toLowerCase() == "badminton") ...[
            Center(
              child: Text(
                "Sets  $setsA - $setsB",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Meta row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sports,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sport,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    court,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamColumn(String teamName) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF243B7C),
          child: const Icon(
            Icons.groups,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            teamName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // INFO BANNER
  // ─────────────────────────────────────────────
  Widget _infoBanner({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TIMELINE
  // ─────────────────────────────────────────────
  Widget _timeline(
    List<Map<String, dynamic>> events,
    String teamA,
    String teamB,
  ) {
    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF151B2E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          "No events yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: events.map((event) {
        final type = (event["type"] ?? "event").toString().toUpperCase();
        final team = (event["team"] ?? "").toString();
        final value = (event["value"] ?? 0).toString();
        final meta = event["meta"];
        final timestamp = _formatTimestamp(event["timestamp"]);

        String subtitle = "$type";
        if (team.isNotEmpty) {
          subtitle += " • $team";
        }

        if (value != "0" && value != "null") {
          subtitle += " (+$value)";
        }

        // Add extra meta info if available
        if (meta is Map && meta.isNotEmpty) {
          if (meta["label"] != null) {
            subtitle += " • ${meta["label"]}";
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF151B2E),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1B4DFF).withOpacity(0.18),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Color(0xFF1B9CFF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (timestamp.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        timestamp,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // TIMESTAMP FORMAT
  // ─────────────────────────────────────────────
  String _formatTimestamp(dynamic raw) {
    try {
      final millis = int.tryParse((raw ?? "").toString());
      if (millis == null) return "";

      final dt = DateTime.fromMillisecondsSinceEpoch(millis);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final suffix = dt.hour >= 12 ? "PM" : "AM";

      return "$hour:$minute $suffix";
    } catch (_) {
      return "";
    }
  }
}