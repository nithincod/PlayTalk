import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/session/session_cubit.dart';
import 'package:playtalk_app/features/super_admin/data/datasources/match_remote_datasource.dart';
import 'package:playtalk_app/features/super_admin/domain/models/tournament_model.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/match_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/team_management_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/tournament_matches_page.dart';

class TournamentDashboardPage extends StatelessWidget {
  final TournamentModel tournament;

  const TournamentDashboardPage({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>().state;

    if (session == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F1424),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1424),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            "Session not found. Please login again.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // ✅ Dashboard route itself creates MatchBloc
    return BlocProvider(
      create: (_) => MatchBloc(
        MatchRemoteDatasource(
          baseUrl: "http://172.70.105.138:3000",
          token: session.token,
        ),
      ),
      child: _TournamentDashboardView(tournament: tournament),
    );
  }
}

class _TournamentDashboardView extends StatelessWidget {
  final TournamentModel tournament;

  const _TournamentDashboardView({
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Tournament Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _headerCard(),
            const SizedBox(height: 18),
            _actionGrid(context),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER CARD
  // =========================================================
  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sportIcon(tournament.sport),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tournament.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(
                icon: Icons.sports,
                text: tournament.sport.toUpperCase(),
                color: Colors.blue,
              ),
              _pill(
                icon: Icons.category_outlined,
                text: tournament.mode.toUpperCase(),
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ACTION GRID
  // =========================================================
  Widget _actionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.groups_rounded,
                title: "Manage Teams",
                subtitle: "Create and manage tournament teams",
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeamManagementPage(
                        tournamentId: tournament.tournamentId,
                        tournamentName: tournament.name,
                        sport: tournament.sport,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                icon: Icons.sports_score_rounded,
                title: "Matches",
                subtitle: "Create and manage tournament matches",
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<MatchBloc>(),
                        child: TournamentMatchesPage(
                          tournament: tournament,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.account_tree_outlined,
                title: "Bracket",
                subtitle: "Generate knockout bracket",
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Bracket page coming in next phase"),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                icon: Icons.insights_outlined,
                title: "Live / Stats",
                subtitle: "Streaming and tournament analytics",
                color: Colors.purple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Live / Stats page coming later"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // SMALL UI HELPERS
  // =========================================================
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2438),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sportIcon(String sport) {
    final s = sport.toLowerCase();

    IconData icon = Icons.sports;

    if (s.contains("football") || s.contains("soccer")) {
      icon = Icons.sports_soccer;
    } else if (s.contains("basketball")) {
      icon = Icons.sports_basketball;
    } else if (s.contains("tennis")) {
      icon = Icons.sports_tennis;
    } else if (s.contains("badminton")) {
      icon = Icons.sports_tennis;
    } else if (s.contains("kabaddi")) {
      icon = Icons.sports_kabaddi;
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.blue),
    );
  }

  Widget _pill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}