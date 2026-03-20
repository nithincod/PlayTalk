import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchEventRemoteDatasource {
  final String baseUrl;
  final String token;

  MatchEventRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<void> submitEvent({
    required String tournamentId,
    required String matchId,
    required Map<String, dynamic> event,
  }) async {
    final response = await http.post(
      Uri.parse(
        "$baseUrl/admin/tournament/$tournamentId/match/$matchId/event",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(event),
    );

    print("SUBMIT EVENT STATUS: ${response.statusCode}");
    print("SUBMIT EVENT BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to submit event: ${response.body}");
    }
  }
}