import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/match_admin_model.dart';

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
  State<AssignMatchAdminPage> createState() =>
      _AssignMatchAdminPageState();
}

class _AssignMatchAdminPageState extends State<AssignMatchAdminPage> {
  MatchAdminModel? selectedAdmin;

  @override
  void initState() {
    super.initState();
    context.read<AssignMatchAdminBloc>().add(LoadMatchAdmins());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssignMatchAdminBloc, AssignMatchAdminState>(
      listener: (context, state) {
        if (state is AssignMatchAdminSuccess) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Assign Match Admin")),
        body: BlocBuilder<AssignMatchAdminBloc,
            AssignMatchAdminState>(
          builder: (context, state) {

            if (state is AssignMatchAdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MatchAdminsLoaded) {
              return Column(
                children: [
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      itemCount: state.admins.length,
                      itemBuilder: (context, i) {
                        final admin = state.admins[i];
                        final selected =
                            selectedAdmin?.adminId ==
                                admin.adminId;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            title: Text(admin.name),
                            subtitle: Text(admin.role),
                            trailing: selected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.blue)
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
                                context
                                    .read<
                                        AssignMatchAdminBloc>()
                                    .add(
                                      AssignMatchAdminPressed(
                                        tournamentId:
                                            widget.tournamentId,
                                        matchId:
                                            widget.matchId,
                                        adminId:
                                            selectedAdmin!
                                                .adminId,
                                        adminName:
                                            selectedAdmin!
                                                .name,
                                      ),
                                    );
                              },
                        child:
                            const Text("Confirm Assignment"),
                      ),
                    ),
                  )
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
