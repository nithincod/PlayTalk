import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/super_admin/domain/models/tournament_model.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/tornament_state.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/tournament_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/tournament_event.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/team_management_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/tournament_details_page.dart';

import '../bloc/match_bloc.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  String search = "";

  @override
  void initState() {
    super.initState();
    context.read<TournamentBloc>().add(LoadTournaments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: _buildAppBar(),
      body: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          if (state is TournamentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TournamentLoaded) {
            final filtered = state.tournaments
                .where(
                  (t) => t.name.toLowerCase().contains(search.toLowerCase()),
                )
                .toList();

            if (filtered.isEmpty) {
              return const Center(
                child: Text(
                  "No tournaments found",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return Column(
              children: [
                _SearchBar(
                  onChanged: (v) => setState(() => search = v),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _TournamentCard(
                      tournament: filtered[i],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              "Failed to load tournaments",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          // TODO: add create tournament flow later if needed
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar() {
  return AppBar(
    backgroundColor: const Color(0xFF0F1424),
    elevation: 0,
    leading: const BackButton(
      color: Colors.white,
    ),
    title: const Text(
      "Tournaments",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search tournaments...",
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1E2438),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final TournamentModel tournament;

  const _TournamentCard({
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2438),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP SECTION
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              debugPrint("Tapped on ${tournament.name}");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MatchBloc>(),
                    child: TournamentDetailsPage(
                      tournament: tournament,
                    ),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                _SportIcon(tournament.sport),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${tournament.sport} • ${tournament.mode}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.blue,
                  size: 16,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // BUTTONS ROW
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.visibility_outlined,
                  label: "Details",
                  color: const Color(0xFF2D5BFF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<MatchBloc>(),
                          child: TournamentDetailsPage(
                            tournament: tournament,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  icon: Icons.groups_rounded,
                  label: "Manage Teams",
                  color: const Color(0xFF10B981),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.14),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _SportIcon extends StatelessWidget {
  final String sport;
  const _SportIcon(this.sport);

  @override
  Widget build(BuildContext context) {
    final s = sport.toLowerCase();

    IconData icon = Icons.sports;

    if (s.contains("football") || s.contains("soccer")) {
      icon = Icons.sports_soccer;
    } else if (s.contains("basketball")) {
      icon = Icons.sports_basketball;
    } else if (s.contains("tennis")) {
      icon = Icons.sports_tennis;
    } else if (s.contains("badminton")) {
      icon = Icons.sports_tennis; // closest racket icon
    } else if (s.contains("kabaddi")) {
      icon = Icons.sports_kabaddi;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.blue,
        size: 22,
      ),
    );
  }
}