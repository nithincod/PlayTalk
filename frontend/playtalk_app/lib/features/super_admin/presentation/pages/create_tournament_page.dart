import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tornament_state.dart';
import '../bloc/tournament_bloc.dart';
import '../bloc/tournament_event.dart';

class CreateTournamentPage extends StatefulWidget {
  const CreateTournamentPage({super.key});

  @override
  State<CreateTournamentPage> createState() => _CreateTournamentPageState();
}

class _CreateTournamentPageState extends State<CreateTournamentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  String _selectedSport = "Badminton";
  String _selectedMode = "Manual";

  @override
  Widget build(BuildContext context) {
    return BlocListener<TournamentBloc, TournamentState>(
      listener: (context, state) {
        if (state is TournamentLoaded) {
          // Success → go back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tournament created successfully")),
          );
          Navigator.pop(context);
        }

        if (state is TournamentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Tournament"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Tournament Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter tournament name";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Sport Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSport,
                  decoration: const InputDecoration(
                    labelText: "Sport",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Badminton", child: Text("Badminton")),
                    DropdownMenuItem(value: "Kabaddi", child: Text("Kabaddi")),
                    DropdownMenuItem(value: "Table Tennis", child: Text("Table Tennis")),
                    DropdownMenuItem(value: "Carrom", child: Text("Carrom")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSport = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Mode Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedMode,
                  decoration: const InputDecoration(
                    labelText: "Tournament Mode",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Manual", child: Text("Manual")),
                    DropdownMenuItem(value: "Automatic", child: Text("Automatic")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMode = value!;
                    });
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<TournamentBloc>().add(
                          CreateTournamentEvent(
                            name: _nameController.text,
                            sport: _selectedSport,
                            mode: _selectedMode,
                          ),
                        );
                      }
                    },
                    child: const Text("Create Tournament"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
