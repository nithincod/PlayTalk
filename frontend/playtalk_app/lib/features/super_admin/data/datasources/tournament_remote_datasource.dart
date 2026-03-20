import 'dart:convert';
import 'package:http/http.dart' as http;

class TournamentRemoteDatasource {
  final String baseUrl;
  final String token;

  TournamentRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<List<dynamic>> fetchTournaments() async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/tournaments"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch tournaments");
    }

    return jsonDecode(response.body);
  }

  Future<void> createTournament({
    required String name,
    required String sport,
    required String mode,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/create-tournament"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "sport": sport,
        "mode": mode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create tournament");
    }
  }
}