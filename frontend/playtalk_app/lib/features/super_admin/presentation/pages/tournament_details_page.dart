import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/create_match_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/tournament_bracket_page.dart';

import '../../domain/models/tournament_model.dart';
import '../../domain/models/match_model.dart';
import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';
import '../bloc/match_state.dart';

import 'package:playtalk_app/features/super_admin/presentation/pages/assign_match_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/assign_match_admin_bloc.dart';
import 'package:playtalk_app/features/super_admin/data/datasources/assign_match_admin_remote_datasource.dart';
import 'package:playtalk_app/core/session/session_cubit.dart';

enum MatchFilter { all, live, upcoming, finished }

class TournamentDetailsPage extends StatefulWidget {
  final TournamentModel tournament;

  const TournamentDetailsPage({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {
  MatchFilter selectedFilter = MatchFilter.all;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchBloc>().add(LoadMatches(widget.tournament.tournamentId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1424),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1424),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          title: Text(
            widget.tournament.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tournament settings coming soon")),
                );
              },
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ],
        ),
        body: BlocBuilder<MatchBloc, MatchState>(
          builder: (context, state) {
            if (state is MatchInitial || state is MatchLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MatchError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (state is MatchLoaded) {
              final allMatches = _matchesForThisTournament(
                state.matches,
                widget.tournament.tournamentId,
              );

              final filteredMatches = _applyFilter(allMatches);

              final liveCount =
                  allMatches.where((m) => m.status == "live").length;
              final upcomingCount =
                  allMatches.where((m) => m.status == "upcoming").length;
              final finishedCount =
                  allMatches.where((m) => m.status == "finished").length;

              debugPrint("TournamentDetailsPage: Loaded ${allMatches.length} matches");

              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<MatchBloc>()
                      .add(LoadMatches(widget.tournament.tournamentId));
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _TournamentHeroCard(
                      tournament: widget.tournament,
                      totalMatches: allMatches.length,
                      liveCount: liveCount,
                      upcomingCount: upcomingCount,
                      finishedCount: finishedCount,
                    ),
                    const SizedBox(height: 16),

                    _ActionButtonsSection(
                      onCreateMatch: _openCreateMatchPage,
                      onTeams: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Teams module wiring next 🔥"),
                          ),
                        );
                      },
                      onBracket: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TournamentBracketPage(
        tournamentId: widget.tournament.tournamentId,
        tournamentName: widget.tournament.name,
      ),
    ),
  );
},
                      onStream: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Live streaming integration page next 🎥"),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    _SectionTitle(
                      title: "Match Control Center",
                      subtitle: "Manage matches, assign admins, and monitor status",
                    ),

                    const SizedBox(height: 14),

                    _buildFilterTabs(),

                    const SizedBox(height: 16),

                    if (filteredMatches.isEmpty)
                      _EmptyMatchesCard(
                        onCreateMatch: _openCreateMatchPage,
                      )
                    else
                      ...filteredMatches.map(_buildMatchCard),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // =========================================================
  // DATA HELPERS
  // =========================================================

  List<MatchModel> _matchesForThisTournament(
    List<MatchModel> matches,
    String tournamentId,
  ) {
    return matches.where((m) {
      return m.tournamentId == tournamentId || m.tournamentId.isEmpty;
    }).toList();
  }

  List<MatchModel> _applyFilter(List<MatchModel> matches) {
    return matches.where((m) {
      switch (selectedFilter) {
        case MatchFilter.live:
          return m.status == "live";
        case MatchFilter.upcoming:
          return m.status == "upcoming";
        case MatchFilter.finished:
          return m.status == "finished";
        case MatchFilter.all:
        default:
          return true;
      }
    }).toList();
  }

  // =========================================================
  // ACTIONS
  // =========================================================

  Future<void> _openCreateMatchPage() async {
  final created = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<MatchBloc>(),
        child: CreateMatchPage(
          tournamentId: widget.tournament.tournamentId,
        ),
      ),
    ),
  );

  if (created == true && mounted) {
    _hasChanges = true;

    context.read<MatchBloc>().add(
          LoadMatches(widget.tournament.tournamentId),
        );

    context.read<MatchBloc>().add(
          LoadAllMatches(),
        );
  }
}

  Future<void> _openAssignAdmin(MatchModel match) async {
    final session = context.read<SessionCubit>().state;

    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session not found. Please login again.")),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AssignMatchAdminBloc(
            AssignMatchAdminRemoteDatasource(
              baseUrl: "http://172.70.105.138:3000",
              token: session.token,
            ),
          ),
          child: AssignMatchAdminPage(
            matchId: match.matchId,
            matchName: match.name,
            tournamentId: widget.tournament.tournamentId,
          ),
        ),
      ),
    );

    if (!mounted) return;

    _hasChanges = true;
    context.read<MatchBloc>().add(
          LoadMatches(widget.tournament.tournamentId),
        );
  }

  // =========================================================
  // UI BUILDERS
  // =========================================================

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip("All", MatchFilter.all),
          _filterChip("Ongoing", MatchFilter.live),
          _filterChip("Upcoming", MatchFilter.upcoming),
          _filterChip("Finished", MatchFilter.finished),
        ],
      ),
    );
  }

  Widget _filterChip(String label, MatchFilter filter) {
    final active = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => setState(() => selectedFilter = filter),
        selectedColor: const Color(0xFF2D5BFF),
        backgroundColor: const Color(0xFF1E2438),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.grey.shade300,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    final bool isLive = match.status == "live";
    final bool isUpcoming = match.status == "upcoming";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2033),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLive
              ? Colors.green.withOpacity(0.35)
              : Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  match.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _statusBadge(match.status),
            ],
          ),

          const SizedBox(height: 16),

          // TEAMS / SCORE
          Row(
            children: [
              Expanded(
                child: _teamBlock(match.teamA),
              ),
              const SizedBox(width: 8),
              _centerScoreBlock(isUpcoming),
              const SizedBox(width: 8),
              Expanded(
                child: _teamBlock(match.teamB),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // META
          Row(
            children: [
              Expanded(
                child: _metaPill(
                  icon: _sportIcon(match.sport),
                  label: match.sport.toUpperCase(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metaPill(
                  icon: Icons.location_on_outlined,
                  label: match.court,
                ),
              ),
            ],
          ),

          // ASSIGN ADMIN BUTTON
          if (isUpcoming && !match.hasAssignedAdmin) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openAssignAdmin(match),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5BFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: const Text(
                  "Assign Match Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else if (match.hasAssignedAdmin) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Match Admin Assigned",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _teamBlock(String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withOpacity(0.08),
          child: const Icon(Icons.groups_rounded, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _centerScoreBlock(bool isUpcoming) {
    return Container(
      width: 86,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            isUpcoming ? "VS" : "LIVE",
            style: TextStyle(
              color: isUpcoming ? Colors.grey : Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUpcoming ? "-- : --" : "View",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaPill({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case "live":
        color = Colors.green;
        text = "LIVE";
        break;
      case "upcoming":
        color = Colors.orange;
        text = "UPCOMING";
        break;
      case "finished":
        color = Colors.grey;
        text = "FINISHED";
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  IconData _sportIcon(String sport) {
    final s = sport.toLowerCase();

    if (s.contains("football") || s.contains("soccer")) {
      return Icons.sports_soccer;
    } else if (s.contains("basketball")) {
      return Icons.sports_basketball;
    } else if (s.contains("tennis") || s.contains("badminton")) {
      return Icons.sports_tennis;
    } else if (s.contains("kabaddi")) {
      return Icons.sports_kabaddi;
    } else if (s.contains("cricket")) {
      return Icons.sports_cricket;
    }

    return Icons.sports;
  }
}

// =============================================================
// HERO CARD
// =============================================================

class _TournamentHeroCard extends StatelessWidget {
  final TournamentModel tournament;
  final int totalMatches;
  final int liveCount;
  final int upcomingCount;
  final int finishedCount;

  const _TournamentHeroCard({
    required this.tournament,
    required this.totalMatches,
    required this.liveCount,
    required this.upcomingCount,
    required this.finishedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D3FFF),
            Color(0xFF142A9E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D5BFF).withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP LABEL
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tournament.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip(tournament.sport.toUpperCase()),
              _heroChip(tournament.mode.toUpperCase()),
              _heroChip("ACTIVE TOURNAMENT"),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _heroStat("Total", totalMatches.toString()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat("Live", liveCount.toString()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat("Upcoming", upcomingCount.toString()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat("Done", finishedCount.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// ACTION BUTTONS
// =============================================================

class _ActionButtonsSection extends StatelessWidget {
  final VoidCallback onCreateMatch;
  final VoidCallback onTeams;
  final VoidCallback onBracket;
  final VoidCallback onStream;

  const _ActionButtonsSection({
    required this.onCreateMatch,
    required this.onTeams,
    required this.onBracket,
    required this.onStream,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PrimaryActionButton(
                label: "Create Match",
                icon: Icons.add_circle_outline,
                onTap: onCreateMatch,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SecondaryActionButton(
                label: "Teams",
                icon: Icons.groups_rounded,
                onTap: onTeams,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SecondaryActionButton(
                label: "Bracket",
                icon: Icons.account_tree_rounded,
                onTap: onBracket,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SecondaryActionButton(
                label: "Stream",
                icon: Icons.live_tv_rounded,
                onTap: onStream,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D5BFF),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2438),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// SECTION TITLE
// =============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// EMPTY STATE
// =============================================================

class _EmptyMatchesCard extends StatelessWidget {
  final VoidCallback onCreateMatch;

  const _EmptyMatchesCard({
    required this.onCreateMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2033),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.06),
            child: const Icon(
              Icons.sports_score_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "No matches yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Create your first match for this tournament and start operations.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreateMatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5BFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Create Match",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}