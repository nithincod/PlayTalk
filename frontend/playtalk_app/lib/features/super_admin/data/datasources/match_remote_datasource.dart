import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchRemoteDatasource {
  final String baseUrl;
  final String token;

  MatchRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<List<dynamic>> fetchMatches(String tournamentId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/tournament/$tournamentId/matches"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("fetchMatches STATUS: ${response.statusCode}");
    print("fetchMatches BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load matches");
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<List<dynamic>> fetchAdminMatches() async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/matches"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("fetchAdminMatches STATUS: ${response.statusCode}");
    print("fetchAdminMatches BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load admin matches");
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

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
      Uri.parse("$baseUrl/admin/tournament/$tournamentId/create-match"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
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

    print("createMatch STATUS: ${response.statusCode}");
    print("createMatch BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to create match");
    }
  }
}