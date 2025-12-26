import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/match_admin/presentation/bloc/match_admin_matches_bloc.dart';

import '../../data/datasources/match_admin_matches_remote_datasource.dart';
import '../../domain/models/match_model.dart';
import '../bloc/match_admin_matches_event.dart';
import '../bloc/match_admin_matches_state.dart';

class AdminHomePage extends StatelessWidget {
  final String adminId;

  const AdminHomePage({
    super.key,
    required this.adminId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminMatchesBloc(
        AdminMatchesRemoteDatasource("http://192.168.1.9:3000"),
      )..add(LoadAdminMatches(adminId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Matches"),
        ),
        body: BlocBuilder<AdminMatchesBloc, AdminMatchesState>(
          builder: (context, state) {
            if (state is AdminMatchesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminMatchesLoaded) {
              if (state.matches.isEmpty) {
                return const Center(
                  child: Text("No assigned matches"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.matches.length,
                itemBuilder: (context, index) {
                  final MatchModel match = state.matches[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(match.name),
                      subtitle: Text(
                        "${match.teamA} vs ${match.teamB}\n${match.court}",
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // PHASE 4.5 → Match Control
                      },
                    ),
                  );
                },
              );
            }

            if (state is AdminMatchesError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
