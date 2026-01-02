// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../data/datasources/live_match_remote_datasource.dart';
// import '../../data/datasources/match_admin_matches_remote_datasource.dart';
// import '../../data/datasources/match_event_remote_datasource.dart';
// import '../../data/datasources/match_lifeycle_remote_datasource.dart';

// import '../../domain/models/match_admin_model.dart';

// import '../bloc/live_match_bloc.dart';
// import '../bloc/match_event_bloc.dart';

// import '../bloc/match_admin_matches_bloc.dart';
// import '../bloc/match_admin_matches_event.dart';
// import '../bloc/match_admin_matches_state.dart';

// import '../bloc/match_lifecycle_bloc.dart';
// import '../bloc/match_lifecycle_event.dart';
// import '../bloc/match_lifecycle_state.dart';

// import 'live_match_page.dart';

// class AdminHomePage extends StatelessWidget {
//   final String adminId;

//   const AdminHomePage({
//     super.key,
//     required this.adminId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         // 🔹 Assigned matches list
//         BlocProvider(
//           create: (_) => AdminMatchesBloc(
//             AdminMatchesRemoteDatasource("http://192.168.1.2:3000"),
//           )..add(LoadAdminMatches(adminId)),
//         ),

//         // 🔹 SINGLE MatchLifecycleBloc (shared everywhere)
//         BlocProvider(
//           create: (_) => MatchLifecycleBloc(
//             MatchLifecycleRemoteDatasource(
//               baseUrl: "http://192.168.1.2:3000",
//               adminId: adminId,
//             ),
//           ),
//         ),
//       ],
//       child: BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
//         listener: (context, state) {
//           if (state is MatchLifecycleSuccess) {
//             // 🔥 Reload matches after start/end
//             context.read<AdminMatchesBloc>().add(
//                   LoadAdminMatches(adminId),
//                 );
//           }
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text("My Assigned Matches"),
//           ),
//           body: BlocBuilder<AdminMatchesBloc, AdminMatchesState>(
//             builder: (context, state) {
//               if (state is AdminMatchesLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (state is AdminMatchesError) {
//                 return Center(child: Text(state.message));
//               }

//               if (state is AdminMatchesLoaded) {
//                 if (state.matches.isEmpty) {
//                   return const Center(
//                     child: Text("No matches assigned"),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: state.matches.length,
//                   itemBuilder: (context, index) {
//                     final MatchAdminModel match = state.matches[index];

//                     final bool isUpcoming = match.status == "upcoming";
//                     final bool isLive = match.status == "live";
//                     final bool isFinished = match.status == "finished";

//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               match.name,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Text("${match.teamA} vs ${match.teamB}"),
//                             Text("Court: ${match.court}"),
//                             const SizedBox(height: 8),
//                             Chip(
//                               label: Text(
//                                 match.status.toUpperCase(),
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                               backgroundColor: isUpcoming
//                                   ? Colors.orange
//                                   : isLive
//                                       ? Colors.green
//                                       : Colors.grey,
//                             ),
//                             const SizedBox(height: 8),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: isFinished
//                                     ? null
//                                     : () {
//                                         if (isUpcoming) {
//                                           // ▶️ START MATCH
//                                           context
//                                               .read<MatchLifecycleBloc>()
//                                               .add(
//                                                 StartMatchPressed(
//                                                   match.tournamentId,
//                                                   match.matchId,
//                                                 ),
//                                               );
//                                         } else if (isLive) {
//                                           // 🔴 ENTER LIVE MATCH
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (_) =>
//                                                   MultiBlocProvider(
//                                                 providers: [
//                                                   // 🔹 Live realtime listener
//                                                   BlocProvider(
//                                                     create: (_) =>
//                                                         LiveMatchBloc(
//                                                       LiveMatchRemoteDatasource(),
//                                                     ),
//                                                   ),

//                                                   // 🔹 Submit scoring events
//                                                   BlocProvider(
//                                                     create: (_) =>
//                                                         MatchEventBloc(
//                                                       MatchEventRemoteDatasource(
//                                                         baseUrl:
//                                                             "http://192.168.1.2:3000",
//                                                         adminId: adminId,
//                                                       ),
//                                                     ),
//                                                   ),

//                                                   // 🔥 PASS SAME MatchLifecycleBloc
//                                                   BlocProvider.value(
//                                                     value: context.read<
//                                                         MatchLifecycleBloc>(),
//                                                   ),
//                                                 ],
//                                                 child: LiveMatchPage(
//                                                   match: match,
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         }
//                                       },
//                                 child: Text(
//                                   isUpcoming
//                                       ? "Start Match"
//                                       : isLive
//                                           ? "Enter Live Control"
//                                           : "Finished",
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }

//               return const SizedBox();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final String adminId;

  const MatchAdminHomeStyledPage({
    super.key,
    required this.adminId,
  });

  @override
  State<MatchAdminHomeStyledPage> createState() =>
      _MatchAdminHomeStyledPageState();
}

class _MatchAdminHomeStyledPageState
    extends State<MatchAdminHomeStyledPage> {
  AdminMatchFilter selectedFilter = AdminMatchFilter.all;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AdminMatchesBloc(
            AdminMatchesRemoteDatasource("http://192.168.1.2:3000"),
          )..add(LoadAdminMatches(widget.adminId)),
        ),
        BlocProvider(
          create: (_) => MatchLifecycleBloc(
            MatchLifecycleRemoteDatasource(
              baseUrl: "http://192.168.1.2:3000",
              adminId: widget.adminId,
            ),
          ),
        ),
      ],
      child: BlocListener<MatchLifecycleBloc, MatchLifecycleState>(
        listener: (context, state) {
          if (state is MatchLifecycleSuccess) {
            context
                .read<AdminMatchesBloc>()
                .add(LoadAdminMatches(widget.adminId));
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
                  return Center(child: Text(state.message));
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
          // bottomNavigationBar: _bottomNav(),
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────
  Widget _header() {
    return const Padding(
      padding: EdgeInsets.all(16),
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
        child: Text("No matches found", style: TextStyle(color: Colors.grey)),
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
              _actionButton(match, widget.adminId),
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
  Widget _actionButton(MatchAdminModel match, String adminId) {
  if (match.status == "finished") return const SizedBox();

  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: Icon(
        match.status == "live"
            ? Icons.videogame_asset
            : Icons.play_arrow,
      ),
      label: Text(
        match.status == "live"
            ? "Enter Live Control"
            : "Start Match",
      ),
      onPressed: () {
        if (match.status == "upcoming") {
          context.read<MatchLifecycleBloc>().add(
                StartMatchPressed(
                  match.tournamentId,
                  match.matchId,
                ),
              );
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
                        baseUrl: "http://192.168.1.2:3000",
                        adminId: adminId,
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


