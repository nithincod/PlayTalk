import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/assign_match_admin_bloc.dart';
import '../bloc/assign_match_admin_event.dart';
import '../bloc/assign_match_admin_state.dart';

class AssignMatchAdminPage extends StatefulWidget {
  final String matchId;
  final String matchName;
  final String tournamentId;

  const AssignMatchAdminPage({
    super.key,
    required this.matchId,
    required this.matchName, required this.tournamentId,
  });

  @override
  State<AssignMatchAdminPage> createState() => _AssignMatchAdminPageState();
}

class _AssignMatchAdminPageState extends State<AssignMatchAdminPage> {
  String? _selectedAdmin;

  // 🔹 TEMP DUMMY ADMINS (next phase: from backend)
  final List<String> _admins = [
    "Nithin",
    "Admin B",
    "Admin C",
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignMatchAdminBloc, AssignMatchAdminState>(
      listener: (context, state) {
        if (state is AssignMatchAdminSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Admin assigned successfully")),
          );
          Navigator.pop(context);
        }

        if (state is AssignMatchAdminFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Assign Match Admin"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match Info
              Text(
                widget.matchName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Match ID: ${widget.matchId}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Admin Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Admin",
                  border: OutlineInputBorder(),
                ),
                value: _selectedAdmin,
                items: _admins
                    .map(
                      (admin) => DropdownMenuItem(
                        value: admin,
                        child: Text(admin),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAdmin = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Assign Button + Loading
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<AssignMatchAdminBloc,
                    AssignMatchAdminState>(
                  builder: (context, state) {
                    if (state is AssignMatchAdminLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ElevatedButton(
                      onPressed: _selectedAdmin == null
                          ? null
                          : () {
                              context
                                  .read<AssignMatchAdminBloc>()
                                  .add(
                                    AssignMatchAdminPressed(
                                      
                                      matchId: widget.matchId,
                                      adminId: "-Oh19pD34L67JX0RbCRr",
                                      adminName: _selectedAdmin!, tournamentId: widget.tournamentId,
                                    ),
                                  );
                            },
                      child: const Text("Assign Admin"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
