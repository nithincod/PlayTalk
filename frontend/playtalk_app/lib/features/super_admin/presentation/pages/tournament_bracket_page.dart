import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:playtalk_app/core/session/session_cubit.dart';
import 'package:playtalk_app/features/super_admin/data/datasources/bracket_remote_datasource.dart';
import 'package:playtalk_app/features/super_admin/domain/models/bracket_match_model.dart';

class TournamentBracketPage extends StatefulWidget {
  final String tournamentId;
  final String tournamentName;

  const TournamentBracketPage({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<TournamentBracketPage> createState() => _TournamentBracketPageState();
}

class _TournamentBracketPageState extends State<TournamentBracketPage> {
  bool isLoading = true;
  bool isGenerating = false;
  String? error;
  List<BracketMatchModel> matches = [];

  @override
  void initState() {
    super.initState();
    _loadBracket();
  }

  Future<BracketRemoteDatasource> _getDatasource() async {
    final session = context.read<SessionCubit>().state;
    if (session == null) {
      throw Exception("Session not found");
    }

    return BracketRemoteDatasource(
      baseUrl: "http://172.70.105.138:3000",
      token: session.token,
    );
  }

  Future<void> _loadBracket() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final datasource = await _getDatasource();
      final result = await datasource.fetchBracket(widget.tournamentId);

      setState(() {
        matches = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _generateBracket() async {
    try {
      setState(() => isGenerating = true);

      final datasource = await _getDatasource();
      await datasource.generateBracket(widget.tournamentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Bracket generated successfully")),
      );

      await _loadBracket();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => isGenerating = false);
      }
    }
  }

  Map<String, List<BracketMatchModel>> get groupedRounds {
    final Map<String, List<BracketMatchModel>> grouped = {};
    for (final match in matches) {
      grouped.putIfAbsent(match.round, () => []);
      grouped[match.round]!.add(match);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        title: Text(
          "${widget.tournamentName} Bracket",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : matches.isEmpty
                  ? _EmptyBracketState(
                      isGenerating: isGenerating,
                      onGenerate: _generateBracket,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBracket,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BracketHeader(
                              totalMatches: matches.length,
                              onRegenerate: null, // disable for now
                            ),
                            const SizedBox(height: 20),
                            ...groupedRounds.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _RoundSection(
                                  roundName: entry.key,
                                  matches: entry.value,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

class _EmptyBracketState extends StatelessWidget {
  final bool isGenerating;
  final VoidCallback onGenerate;

  const _EmptyBracketState({
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2438),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_tree_rounded,
                color: Colors.white70,
                size: 54,
              ),
              const SizedBox(height: 14),
              const Text(
                "No bracket generated yet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Generate knockout bracket automatically from tournament teams.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isGenerating ? null : onGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_fix_high, color: Colors.white),
                  label: Text(
                    isGenerating ? "Generating..." : "Generate Bracket",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BracketHeader extends StatelessWidget {
  final int totalMatches;
  final VoidCallback? onRegenerate;

  const _BracketHeader({
    required this.totalMatches,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D3FFF), Color(0xFF142A9E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tournament Bracket",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Total bracket matches: $totalMatches",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _RoundSection extends StatelessWidget {
  final String roundName;
  final List<BracketMatchModel> matches;

  const _RoundSection({
    required this.roundName,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          roundName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...matches.map((match) => _BracketMatchCard(match: match)),
      ],
    );
  }
}

class _BracketMatchCard extends StatelessWidget {
  final BracketMatchModel match;

  const _BracketMatchCard({
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final isFinished = match.status == "finished";
    final isLive = match.status == "live";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2033),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLive
              ? Colors.green.withOpacity(0.25)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Match ${match.bracketOrder}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _statusBadge(match.status),
            ],
          ),
          const SizedBox(height: 12),
          _teamRow(match.teamA, match.winner == match.teamA),
          const SizedBox(height: 8),
          _teamRow(match.teamB, match.winner == match.teamB),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place_outlined, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(
                match.court,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          if (isFinished && match.winner != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Winner: ${match.winner}",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _teamRow(String team, bool isWinner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.green.withOpacity(0.08)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isWinner ? Icons.emoji_events : Icons.groups_rounded,
            color: isWinner ? Colors.greenAccent : Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              team,
              style: TextStyle(
                color: isWinner ? Colors.greenAccent : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case "live":
        color = Colors.green;
        break;
      case "finished":
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}