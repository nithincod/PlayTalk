import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playtalk_app/features/match_admin/domain/models/match_admin_user_model.dart';

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
    required this.matchName,
    required this.tournamentId,
  });

  @override
  State<AssignMatchAdminPage> createState() => _AssignMatchAdminPageState();
}

class _AssignMatchAdminPageState extends State<AssignMatchAdminPage> {
  MatchAdminUserModel? selectedAdmin;

  @override
  void initState() {
    super.initState();

    // ✅ safer than direct read in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignMatchAdminBloc>().add(LoadMatchAdmins());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignMatchAdminBloc, AssignMatchAdminState>(
      listener: (context, state) {
        if (state is AssignMatchAdminSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Match admin assigned successfully"),
            ),
          );
          Navigator.pop(context);
        }

        if (state is AssignMatchAdminFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Assign Match Admin"),
        ),
        body: BlocBuilder<AssignMatchAdminBloc, AssignMatchAdminState>(
          builder: (context, state) {
            if (state is AssignMatchAdminLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is MatchAdminsLoaded) {
              debugPrint("Loaded admins: ${state.admins.length}");

              // ✅ handle empty list properly
              if (state.admins.isEmpty) {
                return const Center(
                  child: Text(
                    "No approved match admins available",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Select a match admin for ${widget.matchName}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: state.admins.length,
                      itemBuilder: (context, i) {
                        final admin = state.admins[i];
                        final selected =
                            selectedAdmin?.adminId == admin.adminId;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            title: Text(admin.name),
                            subtitle: Text(admin.email), // better than role
                            trailing: selected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                selectedAdmin = admin;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedAdmin == null
                            ? null
                            : () {
                                context.read<AssignMatchAdminBloc>().add(
                                      AssignMatchAdminPressed(
                                        tournamentId: widget.tournamentId,
                                        matchId: widget.matchId,
                                        adminId: selectedAdmin!.adminId,
                                        adminName: selectedAdmin!.name,
                                      ),
                                    );
                              },
                        child: const Text("Confirm Assignment"),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is AssignMatchAdminFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            // ✅ initial state fallback
            return const Center(
              child: Text("Loading match admins..."),
            );
          },
        ),
      ),
    );
  }
}