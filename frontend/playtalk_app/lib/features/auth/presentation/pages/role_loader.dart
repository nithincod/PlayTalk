import 'package:flutter/material.dart';
import '../../../../../core/constants/app_routes.dart';

class RoleLoaderPage extends StatefulWidget {
  const RoleLoaderPage({super.key});

  @override
  State<RoleLoaderPage> createState() => _RoleLoaderPageState();
}

class _RoleLoaderPageState extends State<RoleLoaderPage> {

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    // TEMP MOCK (we’ll connect backend later)
    await Future.delayed(const Duration(seconds: 1));

    // Simulated role from backend
    final role = "super_admin"; 
    // change to: match_admin / user to test

    if (!mounted) return;

    if (role == "super_admin") {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.superAdminHome,
      );
    } else if (role == "match_admin") {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.matchAdminHome,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.userHome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
