import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchLifecycleRemoteDatasource {
  final String baseUrl;
  final String token;

  MatchLifecycleRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<void> startMatch({
    required String matchId,
    required String tournamentId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/match/$matchId/start"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "tournamentId": tournamentId,
      }),
    );

    print("START MATCH STATUS: ${response.statusCode}");
    print("START MATCH BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to start match: ${response.body}");
    }
  }

  Future<void> endMatch({
    required String matchId,
    required String tournamentId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/match/$matchId/end"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "tournamentId": tournamentId,
      }),
    );

    print("END MATCH STATUS: ${response.statusCode}");
    print("END MATCH BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to end match: ${response.body}");
    }
  }
}