import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/session/session_cubit.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/create_match_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/assign_match_page.dart';

import '../../domain/models/tournament_model.dart';
import '../../domain/models/match_model.dart';
import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';
import '../bloc/match_state.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/assign_match_admin_bloc.dart';
import 'package:playtalk_app/features/super_admin/data/datasources/assign_match_admin_remote_datasource.dart';

enum MatchFilter { all, live, upcoming, finished }

class TournamentMatchesPage extends StatefulWidget {
  final TournamentModel tournament;

  const TournamentMatchesPage({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentMatchesPage> createState() => _TournamentMatchesPageState();
}

class _TournamentMatchesPageState extends State<TournamentMatchesPage> {
  MatchFilter selectedFilter = MatchFilter.all;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchBloc>().add(
            LoadMatches(widget.tournament.tournamentId),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tournament.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Tournament Matches",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 34, color: Colors.blue),
             onPressed: () async {
  await Navigator.push(
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

  if (context.mounted) {
    context.read<MatchBloc>().add(
          LoadMatches(widget.tournament.tournamentId),
        );
  }
},
          ),
        ],
      ),
      body: Column(
        children: [
          _summaryStrip(),
          _searchBar(),
          _filterTabs(),
          Expanded(
            child: _matchesList(),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SUMMARY STRIP
  // =========================================================
  Widget _summaryStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _miniInfo(
              icon: Icons.sports,
              title: "Sport",
              value: widget.tournament.sport,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _miniInfo(
              icon: Icons.category_outlined,
              title: "Mode",
              value: widget.tournament.mode,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH BAR
  // =========================================================
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v.trim().toLowerCase()),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search matches...",
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1E2438),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // FILTER TABS
  // =========================================================
  Widget _filterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip("All", MatchFilter.all),
            _filterChip("Ongoing", MatchFilter.live),
            _filterChip("Upcoming", MatchFilter.upcoming),
            _filterChip("Finished", MatchFilter.finished),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, MatchFilter filter) {
    final bool active = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => setState(() => selectedFilter = filter),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: active ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: const Color(0xFF1E2438),
      ),
    );
  }

  // =========================================================
  // MATCH LIST
  // =========================================================
  Widget _matchesList() {
    return BlocBuilder<MatchBloc, MatchState>(
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
          debugPrint(
            'TournamentMatchesPage: Loaded ${state.matches.length} matches',
          );

          final filtered = _applyFilter(
            state.matches,
            widget.tournament.tournamentId,
          );

          if (filtered.isEmpty) {
            return const Center(
              child: Text(
                "No matches found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MatchBloc>().add(
                    LoadMatches(widget.tournament.tournamentId),
                  );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _matchCard(filtered[index]);
              },
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // =========================================================
  // FILTER LOGIC
  // =========================================================
  List<MatchModel> _applyFilter(
    List<MatchModel> matches,
    String tournamentId,
  ) {
    return matches.where((m) {
      final sameTournament =
          m.tournamentId == tournamentId || m.tournamentId.isEmpty;

      if (!sameTournament) return false;

      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.teamA.toLowerCase().contains(query) ||
          m.teamB.toLowerCase().contains(query) ||
          m.sport.toLowerCase().contains(query);

      if (!matchesSearch) return false;

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
  // MATCH CARD
  // =========================================================
  Widget _matchCard(MatchModel match) {
    final bool isUpcoming = match.status == "upcoming";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2438),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  match.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _statusBadge(match.status),
            ],
          ),

          const SizedBox(height: 16),

          // SCORE SECTION
          Row(
            children: [
              Expanded(child: _team(match.teamA)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  isUpcoming ? "VS" : _buildScoreText(match),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(child: _team(match.teamB)),
            ],
          ),

          const SizedBox(height: 14),

          // META
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.sports, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          match.sport,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          match.court,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ASSIGN MATCH ADMIN
          if (isUpcoming && !match.hasAssignedAdmin) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.person_add, color: Color(0xFF3B82F6)),
                label: const Text(
                  "Assign Match Admin",
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  final session = context.read<SessionCubit>().state;

                  if (session == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Session not found. Please login again."),
                      ),
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
                  context.read<MatchBloc>().add(
                        LoadMatches(widget.tournament.tournamentId),
                      );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildScoreText(MatchModel match) {
    final a =  0;
    final b =  0;
    return "$a : $b";
  }

  // =========================================================
  // SMALL UI HELPERS
  // =========================================================
  Widget _miniInfo({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _team(String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF243B7C),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: const Icon(Icons.groups, color: Colors.white),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 90,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case "live":
        color = Colors.green;
        text = "ONGOING";
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}