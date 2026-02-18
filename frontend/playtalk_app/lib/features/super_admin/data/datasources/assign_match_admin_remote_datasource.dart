import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/match_admin_model.dart';

class AssignMatchAdminRemoteDatasource {
  final String baseUrl;
  final String superAdminId;

  AssignMatchAdminRemoteDatasource({
    required this.baseUrl,
    required this.superAdminId,
  });

  // 🔥 NEW — FETCH ADMINS
  Future<List<MatchAdminModel>> fetchAdmins() async {
    final response = await http.get(
      Uri.parse("$baseUrl/superadmin/match-admins"),
      headers: {
        "x-admin-id": superAdminId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch admins");
    }

    final data = jsonDecode(response.body);

    return (data as List)
        .map((e) => MatchAdminModel.fromJson(e))
        .toList();
  }

  // EXISTING
  Future<void> assignAdmin({
    required String tournamentId,
    required String matchId,
    required String adminId,
    required String adminName,
  }) async {
    await http.post(
      Uri.parse(
        "$baseUrl/admin/tournament/$tournamentId/match/$matchId/assign-admin",
      ),
      headers: {
        "Content-Type": "application/json",
        "x-admin-id": superAdminId,
      },
      body: jsonEncode({
        "adminId": adminId,
        "adminName": adminName,
      }),
    );
  }
}
