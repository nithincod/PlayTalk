import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchRemoteDatasource {
  final String baseUrl;
  final String adminId;

  MatchRemoteDatasource({
    required this.baseUrl,
    required this.adminId,
  });

  // ✅ Fetch matches for a tournament
  Future<List<Map<String, dynamic>>> fetchMatches(
      String tournamentId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/admin/tournament/$tournamentId/matches",
      ),
      headers: {
        "x-admin-id": adminId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load matches");
    }

    return List<Map<String, dynamic>>.from(
      json.decode(response.body),
    );
  }

  Future<List<Map<String, dynamic>>> fetchAdminMatches() async {
  final res = await http.get(
    Uri.parse("$baseUrl/admin/matches"),
    headers: {
      "x-admin-id": adminId,
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to fetch matches");
  }

  return List<Map<String, dynamic>>.from(jsonDecode(res.body));
}

  // ✅ Create match INSIDE tournament (Option 2)
  Future<void> createMatch({
    required String tournamentId,
    required String name,
    required String teamA,
    required String teamB,
    required String court,
    required String matchType,
    required String sport,
  }) async {
    final response = await http.post(
      Uri.parse(
        "$baseUrl/admin/tournament/$tournamentId/create-match",
      ),
      headers: {
        "Content-Type": "application/json",
        "x-admin-id": adminId,
      },
      body: jsonEncode({
        "name": name,
        "teamA": teamA,
        "teamB": teamB,
        "court": court,
        "matchType": matchType,
        "sport": sport,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create match");
    }
  }
}
