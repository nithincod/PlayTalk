import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:playtalk_app/core/session/session_cubit.dart';
import 'package:playtalk_app/features/super_admin/data/datasources/team_remote_datasource.dart';
import 'package:playtalk_app/features/super_admin/domain/models/team_model.dart';

import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';

class CreateMatchPage extends StatefulWidget {
  final String tournamentId;

  const CreateMatchPage({
    super.key,
    required this.tournamentId,
  });

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  String selectedSport = "badminton";

  TeamModel? teamA;
  TeamModel? teamB;

  final TextEditingController courtController = TextEditingController();

  bool isLoadingTeams = true;
  bool isCreating = false;
  String? errorMessage;

  List<TeamModel> allTeams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  @override
  void dispose() {
    courtController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD REAL TEAMS
  // =========================================================
  Future<void> _loadTeams() async {
    try {
      final session = context.read<SessionCubit>().state;

      if (session == null) {
        setState(() {
          isLoadingTeams = false;
          errorMessage = "Session not found. Please login again.";
        });
        return;
      }

      final datasource = TeamRemoteDatasource(
        baseUrl: "http://172.70.105.138:3000",
        token: session.token,
      );

      final teams = await datasource.fetchTeams(widget.tournamentId);

      print("🔥 Loaded teams count = ${teams.length}");
      for (final t in teams) {
        print(
          "🔥 TEAM => ${t.name} | sport=${t.sport} | players=${t.players.length}",
        );
      }

      setState(() {
        allTeams = teams;
        isLoadingTeams = false;
      });
    } catch (e) {
      print("❌ _loadTeams error: $e");
      setState(() {
        isLoadingTeams = false;
        errorMessage = "Failed to load teams";
      });
    }
  }

  // =========================================================
  // FILTER TEAMS BY SELECTED SPORT
  // =========================================================
  List<TeamModel> get filteredTeams {
    return allTeams.where((team) {
      return team.sport.toLowerCase() == selectedSport.toLowerCase();
    }).toList();
  }

  // =========================================================
  // CREATE MATCH
  // =========================================================
  Future<void> _submitMatch() async {
    if (teamA == null || teamB == null || courtController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (teamA!.teamId == teamB!.teamId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team A and Team B cannot be same")),
      );
      return;
    }

    setState(() => isCreating = true);

    try {
      final matchBloc = context.read<MatchBloc>();

      matchBloc.add(
        CreateMatchPressed(
          tournamentId: widget.tournamentId,
          sport: selectedSport,
          name: "${teamA!.name} vs ${teamB!.name}",
          teamA: teamA!.name,
          teamB: teamB!.name,
          court: courtController.text.trim(),
          matchType: "league",
        ),
      );

      // tiny wait so event dispatch completes
      await Future.delayed(const Duration(milliseconds: 250));

      if (!mounted) return;

      setState(() => isCreating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Match created successfully")),
      );

      // IMPORTANT: return true so TournamentDetailsPage refreshes
      Navigator.pop(context, true);
    } catch (e) {
      print("❌ create match error: $e");

      if (!mounted) return;
      setState(() => isCreating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create match")),
      );
    }
  }

  // =========================================================
  // SPORT CHANGE
  // =========================================================
  void _onSportChanged(String sport) {
    setState(() {
      selectedSport = sport;
      teamA = null;
      teamB = null;
    });
  }

  // =========================================================
  // UI HELPERS
  // =========================================================
  Widget _sportChip(String sport, IconData icon, String label) {
    final isSelected = selectedSport == sport;

    return GestureDetector(
      onTap: () => _onSportChanged(sport),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D5BFF) : const Color(0xFF1E2438),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2D5BFF)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamDropdown({
    required String hint,
    required TeamModel? value,
    required ValueChanged<TeamModel?> onChanged,
    TeamModel? excludeTeam,
  }) {
    final options = filteredTeams.where((team) {
      if (excludeTeam == null) return true;
      return team.teamId != excludeTeam.teamId;
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2438),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TeamModel>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E2438),
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey),
          ),
          items: options.map((team) {
            return DropdownMenuItem<TeamModel>(
              value: team,
              child: Row(
                children: [
                  const Icon(
                    Icons.groups_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${team.name} (${team.players.length} players)",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _selectedTeamPreview(String label, TeamModel? team) {
    if (team == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            team.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Captain: ${team.captain}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Players: ${team.players.isEmpty ? 'No players found' : team.players.join(', ')}",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BODY
  // =========================================================
  Widget _buildBody() {
    if (isLoadingTeams) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoadingTeams = true;
                    errorMessage = null;
                  });
                  _loadTeams();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (allTeams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2438),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_rounded, color: Colors.white54, size: 48),
                SizedBox(height: 12),
                Text(
                  "No teams available for this tournament",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Create teams first, then come back to create matches.",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final teamsForSport = filteredTeams;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1D3FFF), Color(0xFF142A9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create New Match",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Use real teams from this tournament",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SPORT CATEGORY
          const Text(
            "SPORT CATEGORY",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _sportChip("badminton", Icons.sports_tennis, "Badminton"),
              _sportChip("kabaddi", Icons.sports_kabaddi, "Kabaddi"),
              _sportChip("carrom", Icons.sports, "Carrom"),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "${teamsForSport.length} team(s) available for ${selectedSport[0].toUpperCase()}${selectedSport.substring(1)}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
            ),
          ),

          if (teamsForSport.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.withOpacity(0.15)),
              ),
              child: const Text(
                "No teams found for this sport in this tournament.",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // PARTICIPANTS
          const Text(
            "PARTICIPANTS",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _teamDropdown(
            hint: "Select Home Team",
            value: teamA,
            excludeTeam: teamB,
            onChanged: (v) => setState(() => teamA = v),
          ),
          _selectedTeamPreview("TEAM A", teamA),

          const SizedBox(height: 16),

          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5BFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5BFF).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "VS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _teamDropdown(
            hint: "Select Away Team",
            value: teamB,
            excludeTeam: teamA,
            onChanged: (v) => setState(() => teamB = v),
          ),
          _selectedTeamPreview("TEAM B", teamB),

          const SizedBox(height: 24),

          // LOGISTICS
          const Text(
            "LOGISTICS",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: courtController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "e.g. Main Court A",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E2438),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // MATCH PREVIEW
          if (teamA != null && teamB != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2438),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MATCH PREVIEW",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${teamA!.name} vs ${teamB!.name}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sport: ${selectedSport[0].toUpperCase()}${selectedSport.substring(1)} • Type: League",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isCreating || filteredTeams.length < 2 ? null : _submitMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isCreating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Generate Match",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MAIN BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Match",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(),
    );
  }
}