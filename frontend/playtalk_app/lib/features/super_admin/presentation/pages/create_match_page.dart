import 'package:flutter/material.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _matchNameController = TextEditingController();
  final TextEditingController _teamAController = TextEditingController();
  final TextEditingController _teamBController = TextEditingController();
  final TextEditingController _courtController = TextEditingController();

  String _matchType = "Singles";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Match"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Match Name
              TextFormField(
                controller: _matchNameController,
                decoration: const InputDecoration(
                  labelText: "Match Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter match name"
                        : null,
              ),

              const SizedBox(height: 16),

              // Team A
              TextFormField(
                controller: _teamAController,
                decoration: const InputDecoration(
                  labelText: "Team / Player A",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter Team / Player A"
                        : null,
              ),

              const SizedBox(height: 16),

              // Team B
              TextFormField(
                controller: _teamBController,
                decoration: const InputDecoration(
                  labelText: "Team / Player B",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter Team / Player B"
                        : null,
              ),

              const SizedBox(height: 16),

              // Court
              TextFormField(
                controller: _courtController,
                decoration: const InputDecoration(
                  labelText: "Court / Table No",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter court / table number"
                        : null,
              ),

              const SizedBox(height: 16),

              // Match Type
              DropdownButtonFormField<String>(
                value: _matchType,
                decoration: const InputDecoration(
                  labelText: "Match Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Singles", child: Text("Singles")),
                  DropdownMenuItem(value: "Doubles", child: Text("Doubles")),
                ],
                onChanged: (value) {
                  setState(() {
                    _matchType = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Match created (UI only)"),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Create Match"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
