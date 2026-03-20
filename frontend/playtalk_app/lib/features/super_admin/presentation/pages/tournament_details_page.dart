import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/create_match_page.dart';

import '../../domain/models/tournament_model.dart';
import '../../domain/models/match_model.dart';
import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';
import '../bloc/match_state.dart';
import '../../data/datasources/match_remote_datasource.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/assign_match_page.dart';

import 'package:playtalk_app/features/super_admin/presentation/bloc/assign_match_admin_bloc.dart';
import 'package:playtalk_app/features/super_admin/data/datasources/assign_match_admin_remote_datasource.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/match_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    // Load matches when the page is first opened
    // Use addPostFrameCallback to ensure the context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchBloc>().add(LoadMatches(widget.tournament.tournamentId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        leading: const BackButton(
          color: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.tournament.name,
                style: const TextStyle(
                    color: Colors.white,)),
            const Text(
              "Tournament Matches",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 36, color: Colors.blue),
    
            onPressed: () async {
       Navigator.push(
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

    },
    
          ),
        ],
      ),
      body: Column(
        children: [
          _searchBar(),
          _filterTabs(),
          Expanded(child: _matchesList()),
        ],
      ),
    );
  }

  // ──────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search matches...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
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
        ),
        backgroundColor: const Color(0xFF1E2438),
      ),
    );
  }

  // ──────────────────────────────────────
  Widget _matchesList() {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        // Handle initial state - show loading to trigger fetch
        if (state is MatchInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MatchLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MatchError) {
          return Center(child: Text(state.message));
        }

        if (state is MatchLoaded) {
          debugPrint('TournamentDetailsPage: Loaded ${state.matches.length} matches for tournament ${widget.tournament.tournamentId}');
          
          // Debug: Print tournament IDs from loaded matches
          for (var m in state.matches) {
            debugPrint('  Match ${m.matchId}: tournamentId=${m.tournamentId}, name=${m.name}');
          }
          
          final filtered = _applyFilter(state.matches, widget.tournament.tournamentId);
          debugPrint('TournamentDetailsPage: Filtered to ${filtered.length} matches');

          if (filtered.isEmpty) {
            return Center(
              child: Text("No matches found for tournament ${widget.tournament.tournamentId}"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _matchCard(filtered[index]);
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // ──────────────────────────────────────
  List<MatchModel> _applyFilter(
  List<MatchModel> matches,
  String tournamentId,
) {
  return matches.where((m) {
    // Skip tournamentId check - matches from this endpoint already belong to this tournament
    // Also handle empty tournamentId (legacy data in Firebase)
    final sameTournament = m.tournamentId == tournamentId || m.tournamentId.isEmpty;

    if (!sameTournament) return false;

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


  // ──────────────────────────────────────
  Widget _matchCard(MatchModel match) {
  final bool isLive = match.status == "live";
  final bool isUpcoming = match.status == "upcoming";
  final bool isFinished = match.status == "finished";

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1E2438),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              match.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            _statusBadge(match.status),
          ],
        ),

        const SizedBox(height: 16),

        // 🔹 TEAMS / SCORE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _team(match.teamA),
            Text(
              isUpcoming ? "VS" : "2 : 1",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            _team(match.teamB),
          ],
        ),

        const SizedBox(height: 14),

        // 🔹 META INFO
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_soccer, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(match.sport, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(match.court, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),

        // 🔥 ASSIGN ADMIN (ONLY UPCOMING)
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


  Widget _team(String name) {
    return Column(
      children: [
        const CircleAvatar(radius: 22),
        const SizedBox(height: 6),
        Text(name),
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
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
