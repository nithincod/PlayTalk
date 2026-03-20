import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/session/session_cubit.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();

    // ✅ Delay navigation until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      final token = await firebaseUser.getIdToken(true);

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      final datasource = AuthRemoteDatasource(
        baseUrl: "http://172.70.105.138:3000",
      );

      final profile = await datasource.getCurrentProfile(token);

      final session = AppSession(
        uid: profile["uid"] ?? "",
        name: profile["name"] ?? "",
        email: profile["email"] ?? "",
        role: profile["role"] ?? "user",
        approvalStatus: profile["approvalStatus"] ?? "pending",
        collegeId: profile["collegeId"] ?? "",
        token: token,
      );

      context.read<SessionCubit>().setSession(session);

      if (!mounted) return;

      if (!session.isApproved) {
        Navigator.pushReplacementNamed(context, AppRoutes.pendingApproval);
        return;
      }

      if (session.isSuperAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.superAdminHome);
      } else if (session.isMatchAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.matchAdminHome);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.userHome);
      }
    } catch (e) {
      debugPrint("AUTH GATE ERROR: $e");

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}