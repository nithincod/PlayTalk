import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SuperAdminHomePage extends StatelessWidget {
  const SuperAdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Super Admin Dashboard")),
      body: const Center(child: Text("Super Admin Home")),
    );
  }
}
