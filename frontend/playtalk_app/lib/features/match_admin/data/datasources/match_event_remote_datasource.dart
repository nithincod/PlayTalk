import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchEventRemoteDatasource {
  final String baseUrl;
  final String adminId;

  MatchEventRemoteDatasource({
    required this.baseUrl,
    required this.adminId,
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
        "x-admin-id": adminId,
      },
      body: jsonEncode(event),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to submit event");
    }
  }
}
