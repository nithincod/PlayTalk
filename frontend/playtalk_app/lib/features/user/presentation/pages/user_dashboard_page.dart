import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/match_admin/data/datasources/live_match_remote_datasource.dart';
import 'package:playtalk_app/features/match_admin/presentation/bloc/live_match_bloc.dart';
import 'package:playtalk_app/features/user/presentation/pages/user_match_view_page.dart';
import '../../domain/models/match_model.dart';
import '../bloc/user_matches_bloc.dart';
import '../bloc/user_matches_event.dart';
import '../bloc/user_matches_state.dart';


class UserDashboardPage extends StatefulWidget {
  final String collegeId;
  const UserDashboardPage({super.key, required this.collegeId});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserMatchesBloc>().add(
          StartListeningUserMatches(widget.collegeId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Matches")),
      body: BlocBuilder<UserMatchesBloc, UserMatchesState>(
        builder: (context, state) {
          if (state is UserMatchesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserMatchesLoaded) {
            if (state.matches.isEmpty) {
              return const Center(child: Text("No live matches"));
            }

            return ListView.builder(
              itemCount: state.matches.length,
              itemBuilder: (context, index) {
                final MatchModel match = state.matches[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(
                      "${match.teamA} vs ${match.teamB}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${match.status.toUpperCase()} • ${match.tournamentId}",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => LiveMatchBloc(
        LiveMatchRemoteDatasource(),
      ),
      child: UserMatchViewPage(
        collegeId: widget.collegeId,
        tournamentId: match.tournamentId,
        matchId: match.matchId,
        matchName: "${match.teamA} vs ${match.teamB}",
        
      ),
    ),
  ),
);

                    },
                  ),
                );
              },
            );
          }

          if (state is UserMatchesError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
