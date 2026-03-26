import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/constants/app_routes.dart';
import 'package:playtalk_app/core/session/session_cubit.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/match_bloc.dart';
import 'package:playtalk_app/features/super_admin/presentation/bloc/match_state.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/all_tournaments_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/create_tournament_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/finished_matches_page.dart';
import 'package:playtalk_app/features/super_admin/presentation/pages/ongoing_matches.dart';

import '../bloc/match_event.dart';
import '../bloc/tournament_bloc.dart';
import '../bloc/tornament_state.dart';
import '../bloc/tournament_event.dart';

class SuperAdminHomePage extends StatefulWidget {
  const SuperAdminHomePage({super.key});

  @override
  State<SuperAdminHomePage> createState() => _SuperAdminHomePageState();
}

class _SuperAdminHomePageState extends State<SuperAdminHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchBloc>().add(LoadAllMatches());
      context.read<TournamentBloc>().add(LoadTournaments());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentBloc, TournamentState>(
      builder: (context, state) {
        return BlocBuilder<MatchBloc, MatchState>(
          builder: (context, matchState) {
            print(
                "📊 SuperAdminHomePage matchState = ${matchState.runtimeType}");
            if (matchState is MatchLoaded) {
              print(
                  "📊 Dashboard loaded matches count = ${matchState.matches.length}");
              for (final m in matchState.matches) {
                print("📊 Dashboard match => ${m.name} | ${m.status}");
              }
            }

            // ✅ keep your existing loading logic
            if (state is TournamentLoading || matchState is MatchLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // if (state is TournamentLoaded) {
            //   if (state.tournaments.isEmpty) {
            //     return const Scaffold(
            //       body: Center(child: Text("No tournaments created yet")),
            //     );
            //   }
            // }

            return Scaffold(
              backgroundColor: const Color(0xFF0F1424),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(),
                    const SizedBox(height: 24),
                    _StatsGrid(
                      tournamentState: state,
                      matchState: matchState,
                    ),
                    const SizedBox(height: 24),
                    _QuickActions(),
                    const SizedBox(height: 24),
                    _RecentActivity(),
                  ],
                ),
              ),
              bottomNavigationBar: _BottomNav(
                currentIndex: 0,
                onTap: (index) {
                  if (index == 0) return;

                  if (index == 1) {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => const TournamentManagementPage(),
                    //   ),
                    // );
                  } else if (index == 2) {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => const TeamManagementPage(),
                    //   ),
                    // );
                  } else if (index == 3) {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => const SuperAdminProfilePage(),
                    //   ),
                    // );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFFFD7B5),
              child: Icon(Icons.person, color: Colors.black),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SUPER ADMIN",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "Hello, Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Monday, Oct 24, 2023",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // ✅ SETTINGS DROPDOWN
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings, color: Colors.white),
          color: const Color(0xFF1E2438),
          onSelected: (value) async {
            if (value == "logout") {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                context.read<SessionCubit>().clearSession();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: "logout",
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
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
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final TournamentState tournamentState;
  final MatchState matchState;

  const _StatsGrid({
    super.key,
    required this.tournamentState,
    required this.matchState,
  });

  @override
  Widget build(BuildContext context) {
    int tournaments = 0;
    int live = 0;
    int upcoming = 0;
    int finished = 0;

    // 🎯 TOURNAMENT COUNT
    if (tournamentState is TournamentLoaded) {
      tournaments = (tournamentState as TournamentLoaded).tournaments.length;
    }

    // 🎯 MATCH COUNTS
    if (matchState is MatchLoaded) {
      final matches = (matchState as MatchLoaded).matches;

      live = matches.where((m) => m.status == "live").length;
      upcoming = matches.where((m) => m.status == "upcoming").length;
      finished = matches.where((m) => m.status == "finished").length;
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
            title: "TOURNAMENTS",
            value: tournaments.toString(),
            icon: Icons.emoji_events,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: context.read<TournamentBloc>(),
                      ),
                      BlocProvider.value(
                        value: context.read<MatchBloc>(),
                      ),
                    ],
                    child: const TournamentsPage(), // or AllTournamentsPage()
                  ),
                ),
              );
            }),
        _StatCard(
          title: "ONGOING",
          value: live.toString(),
          icon: Icons.play_circle,
          color: Colors.green,
          badge: live > 0 ? "LIVE" : null,
          onTap: () {
            if (matchState is MatchLoaded) {
              final matches = (matchState as MatchLoaded).matches;
              final ongoingMatches =
                  matches.where((m) => m.status == "live").toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OngoingMatchesPage(
                    matches: ongoingMatches,
                  ),
                ),
              );
            }
          },
        ),
        _StatCard(
          title: "UPCOMING",
          value: upcoming.toString(),
          icon: Icons.schedule,
          color: Colors.orange,
        ),
        _StatCard(
          title: "FINISHED",
          value: finished.toString(),
          icon: Icons.check_circle,
          color: Colors.grey,
          onTap: () {
            if (matchState is MatchLoaded) {
              final matches = (matchState as MatchLoaded).matches;
              final finishedMatches =
                  matches.where((m) => m.status == "finished").toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FinishedMatchesPage(
                    matches: finishedMatches,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2438),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  )
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<TournamentBloc>(),
                    child: const CreateTournamentPage(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E4DFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              "New Tournament",
              style: TextStyle(fontSize: 16),
            ),
          ),
        )
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Recent Activity",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Text("View All", style: TextStyle(color: Colors.blue)),
          ],
        ),
        SizedBox(height: 12),
        _ActivityTile(
          icon: Icons.sports_basketball,
          title: "Basketball Finals - Score Updated",
          subtitle: "Wildcats vs Eagles • Q4 02:30",
          time: "2m ago",
        ),
        _ActivityTile(
          icon: Icons.group_add,
          title: "New Team Registered: Titans",
          subtitle: "Varsity League 2023",
          time: "1h ago",
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2438),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.withOpacity(0.2),
            child: Icon(icon, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF0F1424),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_rounded,
                label: "Home",
                index: 0,
              ),
              _navItem(
                icon: Icons.emoji_events_rounded,
                label: "Tournaments",
                index: 1,
              ),
              _navItem(
                icon: Icons.groups_rounded,
                label: "Teams",
                index: 2,
              ),
              _navItem(
                icon: Icons.person_rounded,
                label: "Profile",
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2D5BFF).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF2D5BFF) : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2D5BFF) : Colors.grey,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
