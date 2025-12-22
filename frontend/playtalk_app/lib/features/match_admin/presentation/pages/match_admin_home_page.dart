import 'package:flutter/material.dart';

class MatchAdminHomePage extends StatelessWidget {
  const MatchAdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Match Admin Dashboard")),
      body: const Center(child: Text("Match Admin Home")),
    );
  }
}
