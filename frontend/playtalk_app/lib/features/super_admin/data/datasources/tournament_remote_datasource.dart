import 'dart:convert';
import 'package:http/http.dart' as http;

class TournamentRemoteDatasource {
  final String baseUrl;
  final String adminId;

  TournamentRemoteDatasource({
    required this.baseUrl,
    required this.adminId,
  });

  Future<List<Map<String, dynamic>>> fetchTournaments() async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/tournaments"),
      headers: {
        "x-admin-id": adminId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load tournaments");
    }

    return List<Map<String, dynamic>>.from(
      json.decode(response.body),
    );
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
      "x-admin-id": adminId,
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


