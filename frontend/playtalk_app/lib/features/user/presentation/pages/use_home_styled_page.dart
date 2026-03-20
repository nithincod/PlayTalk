import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/constants/app_routes.dart';
import 'package:playtalk_app/core/session/session_cubit.dart';
import 'package:playtalk_app/features/user/data/datasources/user_live_match_remote_datasource.dart';
import 'package:playtalk_app/features/user/presentation/bloc/user_live_bloc.dart';
import 'package:playtalk_app/features/user/presentation/pages/user_match_details_page.dart';

import '../../domain/models/user_match_model.dart';
import '../bloc/user_matches_bloc.dart';
import '../bloc/user_matches_event.dart';
import '../bloc/user_matches_state.dart';

enum UserMatchFilter { all, live, upcoming, finished }

class UserHomeStyledPage extends StatefulWidget {
  const UserHomeStyledPage({super.key});

  @override
  State<UserHomeStyledPage> createState() => _UserHomeStyledPageState();
}

class _UserHomeStyledPageState extends State<UserHomeStyledPage> {
  UserMatchFilter selectedFilter = UserMatchFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserMatchesBloc>().add(LoadUserMatches());
    });
  }

  void _handleLogout() {
    final sessionCubit = context.read<SessionCubit>();

    // clearSession() returns void, so NO await
    sessionCubit.clearSession();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      body: SafeArea(
        child: BlocBuilder<UserMatchesBloc, UserMatchesState>(
          builder: (context, state) {
            if (state is UserMatchesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is UserMatchesError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (state is UserMatchesLoaded) {
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
    );
  }

  // HEADER
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Match Center",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Follow live and upcoming matches",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            color: const Color(0xFF1E2438),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
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

  // FILTER TABS
  Widget _filterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterChip("All", UserMatchFilter.all),
          _filterChip("Live", UserMatchFilter.live),
          _filterChip("Upcoming", UserMatchFilter.upcoming),
          _filterChip("Finished", UserMatchFilter.finished),
        ],
      ),
    );
  }

  Widget _filterChip(String label, UserMatchFilter filter) {
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

  // FILTER LOGIC
  List<UserMatchModel> _applyFilter(List<UserMatchModel> matches) {
    switch (selectedFilter) {
      case UserMatchFilter.live:
        return matches.where((m) => m.status == "live").toList();
      case UserMatchFilter.upcoming:
        return matches.where((m) => m.status == "upcoming").toList();
      case UserMatchFilter.finished:
        return matches.where((m) => m.status == "finished").toList();
      case UserMatchFilter.all:
      default:
        return matches;
    }
  }

  // MATCH LIST
  Widget _matchList(List<UserMatchModel> matches) {
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
              const SizedBox(height: 8),

              // Score only for live/finished
              if (match.status != "upcoming")
                Text(
                  "${match.teamAScore} : ${match.teamBScore}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              else
                const Text(
                  "VS",
                  style: TextStyle(
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
              const SizedBox(height: 6),
              Text(
                match.tournamentName,
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

  // STATUS ROW
  Widget _statusRow(UserMatchModel match) {
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

  // ACTION BUTTON
  Widget _actionButton(UserMatchModel match) {
  String buttonText;
  IconData icon;

  if (match.status == "live") {
    buttonText = "Watch Live";
    icon = Icons.play_circle_fill;
  } else if (match.status == "upcoming") {
    buttonText = "View Match";
    icon = Icons.visibility;
  } else {
    buttonText = "View Result";
    icon = Icons.emoji_events;
  }

  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(buttonText),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => UserLiveMatchBloc(
                UserLiveMatchRemoteDatasource(),
              ),
              child: UserMatchDetailsPage(match: match),
            ),
          ),
        );
      },
    ),
  );
}
}
