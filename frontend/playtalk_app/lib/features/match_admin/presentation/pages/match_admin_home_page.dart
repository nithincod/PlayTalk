import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/session/session_cubit.dart';
import 'package:playtalk_app/features/match_admin/data/datasources/live_match_remote_datasource.dart';
import 'package:playtalk_app/features/match_admin/presentation/bloc/live_match_bloc.dart';
import 'package:playtalk_app/features/match_admin/presentation/bloc/match_event_bloc.dart';
import 'package:playtalk_app/features/match_admin/presentation/pages/live_match_page.dart';

import '../../data/datasources/match_admin_matches_remote_datasource.dart';
import '../../data/datasources/match_event_remote_datasource.dart';
import '../../data/datasources/match_lifeycle_remote_datasource.dart';

import '../../domain/models/match_admin_model.dart';

import '../bloc/match_admin_matches_bloc.dart';
import '../bloc/match_admin_matches_event.dart';
import '../bloc/match_admin_matches_state.dart';

import '../bloc/match_lifecycle_bloc.dart';
import '../bloc/match_lifecycle_event.dart';
import '../bloc/match_lifecycle_state.dart';

enum AdminMatchFilter { all, live, upcoming, finished }

class MatchAdminHomeStyledPage extends StatefulWidget {
  const MatchAdminHomeStyledPage({
    super.key,
  });

  @override
  State<MatchAdminHomeStyledPage> createState() =>
      _MatchAdminHomeStyledPageState();
}

class _MatchAdminHomeStyledPageState extends State<MatchAdminHomeStyledPage> {
  AdminMatchFilter selectedFilter = AdminMatchFilter.all;

  // Store bloc references here for easy access
  AdminMatchesBloc? _adminMatchesBloc;
  MatchLifecycleBloc? _lifecycleBloc;

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>().state;

    if (session == null) {
      return const Scaffold(
        body: Center(
          child: Text("Session not found"),
        ),
      );
    }

    // Create blocs and store references
    final adminMatchesBloc = AdminMatchesBloc(
      AdminMatchesRemoteDatasource(
        baseUrl: "http://172.70.105.138:3000",
        token: session.token,
      ),
    )..add(LoadAdminMatches());

    final lifecycleBloc = MatchLifecycleBloc(
      MatchLifecycleRemoteDatasource(
        baseUrl: "http://172.70.105.138:3000",
        token: session.token,
      ),
    );

    // Store in state for access from button
    _adminMatchesBloc = adminMatchesBloc;
    _lifecycleBloc = lifecycleBloc;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: adminMatchesBloc),
        BlocProvider.value(value: lifecycleBloc),
      ],
      child: BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
        listener: (context, state) {
          print("MatchLifecycleBloc state changed: $state");

          if (state is MatchLifecycleSuccess) {
            print("Match started successfully, reloading matches...");
            context.read<AdminMatchesBloc>().add(LoadAdminMatches());
          }

          if (state is MatchLifecycleFailure) {
            print("Match start failed: ${state.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0F1424),
          body: SafeArea(
            child: BlocBuilder<AdminMatchesBloc, AdminMatchesState>(
              builder: (context, state) {
                if (state is AdminMatchesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is AdminMatchesError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (state is AdminMatchesLoaded) {
                  final matches = _applyFilter(state.matches);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      _filterTabs(),
                      Expanded(child: _matchList(matches)),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────
  Widget _header() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Assignments",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Manage your assigned matches",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        PopupMenuButton<String>(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
          ),
          color: const Color(0xFF1E2438),
          onSelected: (value) async {
            if (value == "logout") {
              await _handleLogout();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: "logout",
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _handleLogout() async {
  final sessionCubit = context.read<SessionCubit>();

  // Use whichever method you already have in SessionCubit
  // Example: logout() or clearSession()
  sessionCubit.clearSession();

  if (!mounted) return;

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
}

  // ───────────────── FILTER TABS ─────────────────
  Widget _filterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterChip("All", AdminMatchFilter.all),
          _filterChip("Live", AdminMatchFilter.live),
          _filterChip("Upcoming", AdminMatchFilter.upcoming),
          _filterChip("Finished", AdminMatchFilter.finished),
        ],
      ),
    );
  }

  Widget _filterChip(String label, AdminMatchFilter filter) {
    final active = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => setState(() => selectedFilter = filter),
        selectedColor: const Color(0xFF2D5BFF),
        backgroundColor: const Color(0xFF1E2438),
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  // ───────────────── FILTER LOGIC ─────────────────
  List<MatchAdminModel> _applyFilter(List<MatchAdminModel> matches) {
    switch (selectedFilter) {
      case AdminMatchFilter.live:
        return matches.where((m) => m.status == "live").toList();
      case AdminMatchFilter.upcoming:
        return matches.where((m) => m.status == "upcoming").toList();
      case AdminMatchFilter.finished:
        return matches.where((m) => m.status == "finished").toList();
      case AdminMatchFilter.all:
      default:
        return matches;
    }
  }

  // ───────────────── MATCH LIST ─────────────────
  Widget _matchList(List<MatchAdminModel> matches) {
    if (matches.isEmpty) {
      return const Center(
        child: Text(
          "No matches found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final isLive = match.status == "live";
        final isUpcoming = match.status == "upcoming";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2438),
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(
                width: 4,
                color: isLive
                    ? Colors.green
                    : isUpcoming
                        ? Colors.orange
                        : Colors.grey,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusRow(match),
              const SizedBox(height: 12),
              Text(
                "${match.teamA} vs ${match.teamB}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                match.court,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 14),
              _actionButton(match),
            ],
          ),
        );
      },
    );
  }

  // ───────────────── STATUS ROW ─────────────────
  Widget _statusRow(MatchAdminModel match) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          match.sport.toUpperCase(),
          style: const TextStyle(color: Colors.grey),
        ),
        Chip(
          label: Text(
            match.status.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: match.status == "live"
              ? Colors.green
              : match.status == "upcoming"
                  ? Colors.orange
                  : Colors.grey,
        ),
      ],
    );
  }

  // ───────────────── ACTION BUTTON ─────────────────
  Widget _actionButton(MatchAdminModel match) {
    final session = context.read<SessionCubit>().state;

    if (session == null) {
      return const SizedBox();
    }

    if (match.status == "finished") return const SizedBox();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          match.status == "live" ? Icons.videogame_asset : Icons.play_arrow,
        ),
        label: Text(
          match.status == "live" ? "Enter Live Control" : "Start Match",
        ),
        onPressed: () async {
          final adminMatchesBloc = _adminMatchesBloc;
          final lifecycleBloc = _lifecycleBloc;

          if (adminMatchesBloc == null || lifecycleBloc == null) {
            print("ERROR: Blocs not initialized");
            return;
          }

          print(
              "Button pressed for match: ${match.matchId}, status: ${match.status}");

          if (match.status == "upcoming") {
            lifecycleBloc.add(
              StartMatchPressed(
                match.tournamentId,
                match.matchId,
              ),
            );

            // small wait so backend update finishes
            await Future.delayed(const Duration(milliseconds: 500));

            adminMatchesBloc.add(LoadAdminMatches());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    // 🔹 Live realtime listener
                    BlocProvider(
                      create: (_) => LiveMatchBloc(
                        LiveMatchRemoteDatasource(),
                      ),
                    ),

                    // 🔹 Submit scoring events
                    BlocProvider(
                      create: (_) => MatchEventBloc(
                        MatchEventRemoteDatasource(
                          baseUrl: "http://172.70.105.138:3000",
                          token: session.token,
                        ),
                      ),
                    ),

                    // 🔥 PASS SAME MatchLifecycleBloc
                    BlocProvider.value(
                      value: context.read<MatchLifecycleBloc>(),
                    ),
                  ],
                  child: LiveMatchPage(
                    match: match,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // ───────────────── BOTTOM NAV ─────────────────
  Widget _bottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0F1424),
      selectedItemColor: const Color(0xFF2D5BFF),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Matches",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Alerts",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
      ],
    );
  }
}


