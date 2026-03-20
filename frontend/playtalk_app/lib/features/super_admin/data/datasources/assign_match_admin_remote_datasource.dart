import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:playtalk_app/features/match_admin/domain/models/match_admin_user_model.dart';

class AssignMatchAdminRemoteDatasource {
  final String baseUrl;
  final String token;

  AssignMatchAdminRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<List<MatchAdminUserModel>> fetchAdmins() async {
    final response = await http.get(
      Uri.parse("$baseUrl/superadmin/match-admins"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    print("FETCH ADMINS RESPONSE: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch admins");
    }

    final List data = jsonDecode(response.body);

    return data
        .map((json) => MatchAdminUserModel.fromJson(json))
        .toList();
  }

  Future<void> assignAdmin({
    required String tournamentId,
    required String matchId,
    required String adminId,
    required String adminName,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/tournament/$tournamentId/match/$matchId/assign-admin"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "adminId": adminId,
        "adminName": adminName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to assign admin");
    }
  }
}