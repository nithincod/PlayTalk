import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/user/presentation/bloc/user_live_bloc.dart';
import 'package:playtalk_app/features/user/presentation/pages/user_live_stream_page.dart';

import '../../domain/models/user_match_model.dart';
import '../bloc/user_live_match_event.dart';
import '../bloc/user_live_match_state.dart';

class _FeedItem {
  final String id;
  final String kind; // event | commentary
  final int timestamp;
  final Map<String, dynamic> data;

  _FeedItem({
    required this.id,
    required this.kind,
    required this.timestamp,
    required this.data,
  });
}

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

          int _toInt(dynamic value) {
            return int.tryParse((value ?? 0).toString()) ?? 0;
          }

          // ─────────────────────────────────────────────
          // BASIC FIELDS
          // ─────────────────────────────────────────────
          final String teamA = (liveData["teamA"] ?? baseMatch.teamA).toString();
          final String teamB = (liveData["teamB"] ?? baseMatch.teamB).toString();
          final String sport = (liveData["sport"] ?? baseMatch.sport).toString();
          final String court = (liveData["court"] ?? baseMatch.court).toString();
          final String name = (liveData["name"] ?? baseMatch.name).toString();
          final String status =
              (liveData["status"] ?? baseMatch.status).toString().toLowerCase();

          final String round = (liveData["round"] ?? "").toString();

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
          // SCORE PARSING
          // ─────────────────────────────────────────────
          int teamAScore = baseMatch.teamAScore;
          int teamBScore = baseMatch.teamBScore;

          final score = liveData["score"];

          if (score is Map) {
            final scoreMap = Map<String, dynamic>.from(score);

            if (scoreMap["currentSet"] is Map) {
              final currentSet = Map<String, dynamic>.from(scoreMap["currentSet"]);
              teamAScore = _toInt(currentSet["A"]);
              teamBScore = _toInt(currentSet["B"]);
            } else {
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

          int setsA = 0;
          int setsB = 0;
          Map<String, dynamic> lastCompletedSet = {};
          Map<String, dynamic> momentum = {};
          String winner = "";

          if (score is Map) {
            final scoreMap = Map<String, dynamic>.from(score);
            setsA = _toInt(scoreMap["setsA"]);
            setsB = _toInt(scoreMap["setsB"]);

            if (scoreMap["lastCompletedSet"] is Map) {
              lastCompletedSet =
                  Map<String, dynamic>.from(scoreMap["lastCompletedSet"]);
            }

            if (scoreMap["momentum"] is Map) {
              momentum = Map<String, dynamic>.from(scoreMap["momentum"]);
            }

            winner = (scoreMap["winner"] ?? "").toString();
          }

          winner = (liveData["winner"] ?? winner).toString();

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

          // fallback derive score if needed
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

          // ─────────────────────────────────────────────
          // COMMENTARY PARSING
          // Supports:
          // 1) event.commentary
          // 2) match.commentary node
          // ─────────────────────────────────────────────
          List<Map<String, dynamic>> commentaryItems = [];

          // A) commentary inside events
          for (final e in events) {
            final rawCommentary = e["commentary"];
            if (rawCommentary is Map) {
              final commentaryMap = Map<String, dynamic>.from(rawCommentary);
              commentaryItems.add({
                "commentaryId":
                    (commentaryMap["commentaryId"] ?? e["eventId"]).toString(),
                ...commentaryMap,
                "linkedEventId": e["eventId"],
              });
            }
          }

          // B) dedicated commentary node
          final rawCommentaryNode = liveData["commentary"];
          if (rawCommentaryNode is Map) {
            final commentaryMap = Map<String, dynamic>.from(rawCommentaryNode);

            final parsedNodeCommentary = commentaryMap.entries.map((entry) {
              final val = Map<String, dynamic>.from(entry.value);
              return {
                "commentaryId": entry.key,
                ...val,
              };
            }).toList();

            commentaryItems.addAll(parsedNodeCommentary);
          }

          // Deduplicate commentary
          final seenCommentaryIds = <String>{};
          commentaryItems = commentaryItems.where((c) {
            final id = (c["commentaryId"] ?? "").toString();
            if (id.isEmpty) return false;
            if (seenCommentaryIds.contains(id)) return false;
            seenCommentaryIds.add(id);
            return true;
          }).toList();

          commentaryItems.sort(
            (a, b) => _toInt(b["createdAt"] ?? b["timestamp"])
                .compareTo(_toInt(a["createdAt"] ?? a["timestamp"])),
          );

          // ─────────────────────────────────────────────
          // UNIFIED FEED
          // ─────────────────────────────────────────────
          List<_FeedItem> feed = [];

          for (final e in events) {
            feed.add(
              _FeedItem(
                id: (e["eventId"] ?? "").toString(),
                kind: "event",
                timestamp: _toInt(e["timestamp"]),
                data: e,
              ),
            );
          }

          for (final c in commentaryItems) {
            feed.add(
              _FeedItem(
                id: (c["commentaryId"] ?? "").toString(),
                kind: "commentary",
                timestamp: _toInt(c["createdAt"] ?? c["timestamp"]),
                data: c,
              ),
            );
          }

          feed.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          final highlights =
              commentaryItems.where((c) => c["important"] == true).toList();

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
                  round: round,
                  winner: winner,
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

                if (isUpcoming)
                  _infoBanner(
                    icon: Icons.schedule,
                    text: "This match has not started yet.",
                    color: Colors.orange,
                  ),

                if (isFinished)
                  _infoBanner(
                    icon: Icons.emoji_events,
                    text: winner.isNotEmpty
                        ? "Match finished. Winner: $winner"
                        : "Match finished. Final result shown above.",
                    color: Colors.grey,
                  ),

                if (isLive)
                  _livePulseBanner(
                    sport: sport,
                    teamAScore: teamAScore,
                    teamBScore: teamBScore,
                    setsA: setsA,
                    setsB: setsB,
                  ),

                if (sport.toLowerCase() == "badminton")
                  _badmintonInsights(
                    setsA: setsA,
                    setsB: setsB,
                    lastCompletedSet: lastCompletedSet,
                    momentum: momentum,
                    winner: winner,
                    status: status,
                  ),

                if (highlights.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    "Highlights",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _highlightsSection(highlights),
                ],

                if (isLive || feed.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    "Live Commentary",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _cricbuzzFeed(feed),
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
    required String round,
    required String winner,
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

          if (round.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              round,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Teams + score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _teamColumn(teamA),
              Column(
                children: [
                  Text(
                    "$teamAScore : $teamBScore",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (winner.isNotEmpty && status == "finished") ...[
                    const SizedBox(height: 6),
                    Text(
                      "Winner: $winner",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
              _teamColumn(teamB),
            ],
          ),

          const SizedBox(height: 18),

          if (sport.toLowerCase() == "badminton") ...[
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Sets  $setsA - $setsB",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

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

  Widget _livePulseBanner({
    required String sport,
    required int teamAScore,
    required int teamBScore,
    required int setsA,
    required int setsB,
  }) {
    String text = "Live updates coming in";

    if (sport.toLowerCase() == "badminton") {
      text = "Current set score: $teamAScore-$teamBScore • Sets: $setsA-$setsB";
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BADMINTON INSIGHTS
  // ─────────────────────────────────────────────
  Widget _badmintonInsights({
    required int setsA,
    required int setsB,
    required Map<String, dynamic> lastCompletedSet,
    required Map<String, dynamic> momentum,
    required String winner,
    required String status,
  }) {
    final hasLastSet = lastCompletedSet.isNotEmpty;
    final hasMomentum = momentum.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Badminton Insights",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          _insightRow("Sets Score", "$setsA - $setsB"),
          if (hasLastSet)
            _insightRow(
              "Last Completed Set",
              "Set ${lastCompletedSet["setNumber"] ?? "-"} • "
              "${lastCompletedSet["scoreA"] ?? 0}-${lastCompletedSet["scoreB"] ?? 0} • "
              "${lastCompletedSet["winner"] ?? ""}",
            ),
          if (hasMomentum)
            _insightRow(
              "Momentum",
              "${momentum["team"] ?? ""} (${momentum["streak"] ?? 0} straight points)",
            ),
          if (status == "finished" && winner.isNotEmpty)
            _insightRow("Winner", winner),
        ],
      ),
    );
  }

  Widget _insightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HIGHLIGHTS
  // ─────────────────────────────────────────────
  Widget _highlightsSection(List<Map<String, dynamic>> highlights) {
    return Column(
      children: highlights.take(5).map((c) {
        final text = (c["text"] ?? "").toString();
        final time = _formatTimestamp(c["createdAt"] ?? c["timestamp"]);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        time,
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
  // CRICBUZZ STYLE FEED
  // ─────────────────────────────────────────────
  Widget _cricbuzzFeed(List<_FeedItem> feed) {
    if (feed.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF151B2E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          "No updates yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: feed.map((item) {
        if (item.kind == "commentary") {
          final c = item.data;
          final text = (c["text"] ?? "Live update").toString();
          final category = (c["category"] ?? "update").toString();
          final important = c["important"] == true;
          final time = _formatTimestamp(item.timestamp);

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: important
                  ? Colors.amber.withOpacity(0.10)
                  : const Color(0xFF151B2E),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: important
                    ? Colors.amber.withOpacity(0.35)
                    : Colors.white.withOpacity(0.04),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: important
                        ? Colors.amber.withOpacity(0.18)
                        : const Color(0xFF1B4DFF).withOpacity(0.18),
                  ),
                  child: Icon(
                    important ? Icons.campaign : Icons.mic,
                    color: important ? Colors.amber : const Color(0xFF1B9CFF),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category.isNotEmpty)
                        Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            color: important ? Colors.amber : Colors.blueAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      if (category.isNotEmpty) const SizedBox(height: 6),
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      if (time.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final e = item.data;
        final type = (e["type"] ?? "event").toString().toUpperCase();
        final team = (e["team"] ?? "").toString();
        final value = (e["value"] ?? 0).toString();
        final timestamp = _formatTimestamp(item.timestamp);

        String subtitle = type;
        if (team.isNotEmpty) subtitle += " • $team";
        if (value != "0" && value != "null") subtitle += " (+$value)";

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
                        fontSize: 15,
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