// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/tornament_state.dart';
// import '../bloc/tournament_bloc.dart';
// import '../bloc/tournament_event.dart';

// class CreateTournamentPage extends StatefulWidget {
//   const CreateTournamentPage({super.key});

//   @override
//   State<CreateTournamentPage> createState() => _CreateTournamentPageState();
// }

// class _CreateTournamentPageState extends State<CreateTournamentPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();

//   String _selectedSport = "Badminton";
//   String _selectedMode = "Manual";

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<TournamentBloc, TournamentState>(
//       listener: (context, state) {
//         if (state is TournamentLoaded) {
//           // Success → go back
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Tournament created successfully")),
//           );
//           Navigator.pop(context);
//         }

//         if (state is TournamentError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message)),
//           );
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Create Tournament"),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Tournament Name
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     labelText: "Tournament Name",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please enter tournament name";
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 // Sport Dropdown
//                 DropdownButtonFormField<String>(
//                   value: _selectedSport,
//                   decoration: const InputDecoration(
//                     labelText: "Sport",
//                     border: OutlineInputBorder(),
//                   ),
//                   items: const [
//                     DropdownMenuItem(value: "Badminton", child: Text("Badminton")),
//                     DropdownMenuItem(value: "Kabaddi", child: Text("Kabaddi")),
//                     DropdownMenuItem(value: "Table Tennis", child: Text("Table Tennis")),
//                     DropdownMenuItem(value: "Carrom", child: Text("Carrom")),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedSport = value!;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 16),

//                 // Mode Dropdown
//                 DropdownButtonFormField<String>(
//                   value: _selectedMode,
//                   decoration: const InputDecoration(
//                     labelText: "Tournament Mode",
//                     border: OutlineInputBorder(),
//                   ),
//                   items: const [
//                     DropdownMenuItem(value: "Manual", child: Text("Manual")),
//                     DropdownMenuItem(value: "Automatic", child: Text("Automatic")),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedMode = value!;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 24),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         context.read<TournamentBloc>().add(
//                           CreateTournamentEvent(
//                             name: _nameController.text,
//                             sport: _selectedSport,
//                             mode: _selectedMode,
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text("Create Tournament"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tournament_bloc.dart';
import '../bloc/tournament_event.dart';

class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage> {
  final TextEditingController _nameController = TextEditingController();

  String selectedSport = "Badminton";
  String selectedMode = "automatic";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1424),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create Tournament"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Tournament Name"),
            _nameField(),

            const SizedBox(height: 24),
            _title("Select Sport"),
            _sportGrid(),

            const SizedBox(height: 24),
            _title("Tournament Mode"),
            _modeToggle(),

            const SizedBox(height: 40),
            _submitButton(context),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "e.g., Inter-Year Badminton Championship",
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E2438),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  Widget _sportGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _sportTile("Badminton", Icons.sports_tennis),
        _sportTile("Kabaddi", Icons.groups),
        _sportTile("Table Tennis", Icons.sports),
        _sportTile("Carrom", Icons.circle),
      ],
    );
  }

  Widget _sportTile(String sport, IconData icon) {
    final bool selected = selectedSport == sport;

    return GestureDetector(
      onTap: () => setState(() => selectedSport = sport),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2438),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 36,
                color: selected ? Colors.blue : Colors.grey),
            const SizedBox(height: 10),
            Text(
              sport,
              style: TextStyle(
                color: selected ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  Widget _modeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2438),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _modeButton("Automatic", "automatic"),
          _modeButton("Manual", "manual"),
        ],
      ),
    );
  }

  Widget _modeButton(String label, String value) {
    final bool active = selectedMode == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMode = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  Widget _submitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tournament name required")),
          );
          return;
        }

        context.read<TournamentBloc>().add(
              CreateTournamentEvent(
                name: _nameController.text.trim(),
                sport: selectedSport,
                mode: selectedMode,
              ),
            );

        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2F49F5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text(
        "Submit",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
