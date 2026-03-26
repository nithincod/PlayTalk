import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/core/session/session_cubit.dart';

import '../../data/datasources/team_remote_datasource.dart';
import '../../domain/models/team_model.dart';
import '../bloc/team_bloc.dart';
import '../bloc/team_event.dart';
import '../bloc/team_state.dart';

class TeamManagementPage extends StatelessWidget {
  final String tournamentId;
  final String tournamentName;
  final String sport;

  const TeamManagementPage({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.sport,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>().state;

    if (session == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1424),
        body: Center(
          child: Text(
            "Session not found",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => TeamBloc(
        TeamRemoteDatasource(
          baseUrl: "http://172.70.105.138:3000",
          token: session.token,
        ),
      )..add(LoadTeams(tournamentId)),
      child: _TeamManagementView(
        tournamentId: tournamentId,
        tournamentName: tournamentName,
        sport: sport,
      ),
    );
  }
}

class _TeamManagementView extends StatelessWidget {
  final String tournamentId;
  final String tournamentName;
  final String sport;

  const _TeamManagementView({
    required this.tournamentId,
    required this.tournamentName,
    required this.sport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        title: Text(
          "$tournamentName Teams",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2D5BFF),
        onPressed: () => _showCreateTeamDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Create Team",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocConsumer<TeamBloc, TeamState>(
        listener: (context, state) {
          if (state is TeamActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is TeamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TeamLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TeamLoaded) {
            if (state.teams.isEmpty) {
              return const Center(
                child: Text(
                  "No teams yet",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.teams.length,
              itemBuilder: (context, index) {
                final team = state.teams[index];
                return _teamCard(context, team);
              },
            );
          }

          if (state is TeamError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _teamCard(BuildContext context, TeamModel team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5BFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF2D5BFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  team.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<TeamBloc>().add(
                        DeleteTeamPressed(
                          tournamentId: tournamentId,
                          teamId: team.teamId,
                        ),
                      );
                },
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _metaRow("Sport", team.sport.toUpperCase()),
          _metaRow("Captain", team.captain.isEmpty ? "-" : team.captain),
          _metaRow("Players", "${team.players.length}"),

          if (team.players.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "Players",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: team.players.map((player) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    player,
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    final captainController = TextEditingController();
    final playersController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF151B2E),
        title: const Text(
          "Create Team",
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _darkField(
                controller: nameController,
                label: "Team Name",
              ),
              const SizedBox(height: 12),
              _darkField(
                controller: captainController,
                label: "Captain (optional)",
              ),
              const SizedBox(height: 12),
              _darkField(
                controller: playersController,
                label: "Players (comma separated)",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final captain = captainController.text.trim();
              final players = playersController.text
                  .split(",")
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Team name is required")),
                );
                return;
              }

              context.read<TeamBloc>().add(
                    CreateTeamPressed(
                      tournamentId: tournamentId,
                      name: name,
                      sport: sport,
                      players: players,
                      captain: captain,
                    ),
                  );

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5BFF),
            ),
            child: const Text(
              "Create",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF2D5BFF),
          ),
        ),
      ),
    );
  }
}