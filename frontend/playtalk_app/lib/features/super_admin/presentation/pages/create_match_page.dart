import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';

// class CreateMatchPage extends StatefulWidget {
//   final String tournamentId;

//   const CreateMatchPage({
//     super.key,
//     required this.tournamentId,
//   });

//   @override
//   State<CreateMatchPage> createState() => _CreateMatchPageState();
// }

// class _CreateMatchPageState extends State<CreateMatchPage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _matchNameController = TextEditingController();
//   final TextEditingController _teamAController = TextEditingController();
//   final TextEditingController _teamBController = TextEditingController();
//   final TextEditingController _courtController = TextEditingController();


//   String _matchType = "Singles";
//   String _selectedSport = "Badminton";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create Match"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               // Match Name
//               TextFormField(
//                 controller: _matchNameController,
//                 decoration: const InputDecoration(
//                   labelText: "Match Name",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty
//                         ? "Enter match name"
//                         : null,
//               ),

//               const SizedBox(height: 16),

//               // Team A
//               TextFormField(
//                 controller: _teamAController,
//                 decoration: const InputDecoration(
//                   labelText: "Team / Player A",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty
//                         ? "Enter Team / Player A"
//                         : null,
//               ),

//               const SizedBox(height: 16),

//               // Team B
//               TextFormField(
//                 controller: _teamBController,
//                 decoration: const InputDecoration(
//                   labelText: "Team / Player B",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty
//                         ? "Enter Team / Player B"
//                         : null,
//               ),

//               const SizedBox(height: 16),

//               // Court
//               TextFormField(
//                 controller: _courtController,
//                 decoration: const InputDecoration(
//                   labelText: "Court / Table No",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty
//                         ? "Enter court / table number"
//                         : null,
//               ),

//               const SizedBox(height: 16),

//               DropdownButtonFormField<String>(
//   value: _selectedSport, // Use the string variable
//   decoration: const InputDecoration(
//     labelText: "Sport Type",
//     border: OutlineInputBorder(),
//   ),
//   items: const [
//     DropdownMenuItem(value: "Badminton", child: Text("Badminton")),
//     DropdownMenuItem(value: "Kabaddi", child: Text("Kabaddi")),
//   ],
//   onChanged: (value) {
//     setState(() {
//       _selectedSport = value!; // Update the string variable
//     });
//   },
// ),

//               const SizedBox(height: 16),

//               // Match Type
//               DropdownButtonFormField<String>(
//                 value: _matchType,
//                 decoration: const InputDecoration(
//                   labelText: "Match Type",
//                   border: OutlineInputBorder(),
//                 ),
//                 items: const [
//                   DropdownMenuItem(value: "Singles", child: Text("Singles")),
//                   DropdownMenuItem(value: "Doubles", child: Text("Doubles")),
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     _matchType = value!;
//                   });
//                 },
//               ),

//               const SizedBox(height: 24),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // ✅ REAL MATCH CREATION
//                       context.read<MatchBloc>().add(
//                             CreateMatchEvent(
//                               tournamentId: widget.tournamentId,
//                               name: _matchNameController.text,
//                               teamA: _teamAController.text,
//                               teamB: _teamBController.text,
//                               court: _courtController.text,
//                               matchType: _matchType,
//                               status: "upcoming", 
//                               sport: _selectedSport,
//                             ),
//                           );

//                       Navigator.pop(context);
//                     }
//                   },
//                   child: const Text("Create Match"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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
  String selectedSport = "Basketball";
  String? teamA;
  String? teamB;

  final TextEditingController courtController = TextEditingController();

  @override
  void dispose() {
    courtController.dispose();
    super.dispose();
  }

  void _submitMatch() {
  if (teamA == null ||
      teamB == null ||
      courtController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  final matchBloc = context.read<MatchBloc>();
  

  matchBloc.add(
    CreateMatchEvent(
      tournamentId: widget.tournamentId,
      sport: selectedSport.toLowerCase(),
      name: "$teamA vs $teamB",
      teamA: teamA!,
      teamB: teamB!,
      court: courtController.text.trim(),
      matchType: "league",
      status: "upcoming",
    ),
  );

  // 🔥 FORCE RELOAD USING SAME BLOC
  matchBloc.add(
    LoadMatches(widget.tournamentId),
  );

  Navigator.pop(context); 
}


  Widget _sportChip(String sport, IconData icon) {
    final isSelected = selectedSport == sport;

    return GestureDetector(
      onTap: () {
        setState(() => selectedSport = sport);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D5BFF) : const Color(0xFF1E2438),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              sport,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2438),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1E2438),
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items: const [
          DropdownMenuItem(value: "Team A", child: Text("Team A")),
          DropdownMenuItem(value: "Team B", child: Text("Team B")),
          DropdownMenuItem(value: "Team C", child: Text("Team C")),
        ],
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create Match"),
        actions: [
          TextButton(
            onPressed: _submitMatch,
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SPORT CATEGORY",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    _sportChip("Badminton", Icons.sports_tennis),
    _sportChip("Kabaddi", Icons.sports_martial_arts),
    _sportChip("Carrom", Icons.sports_esports),
  ],
),

             SizedBox(height: 24),

            const Text("PARTICIPANTS",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            _dropdown(
              hint: "Select Home Team",
              onChanged: (v) => setState(() => teamA = v),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D5BFF),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  "VS",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _dropdown(
              hint: "Select Away Team",
              onChanged: (v) => setState(() => teamB = v),
            ),

            const SizedBox(height: 24),
            const Text("LOGISTICS",
                style: TextStyle(color: Colors.grey)),
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
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitMatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Generate Match",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
