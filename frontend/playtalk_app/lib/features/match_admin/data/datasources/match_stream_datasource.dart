import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchStreamRemoteDatasource {
  final String baseUrl;
  final String token;

  MatchStreamRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<Map<String, dynamic>> updateStreamStatus({
    required String tournamentId,
    required String matchId,
    required bool isStreaming,
    required String streamKey,
    required String hlsUrl,
  }) async {
    final url = Uri.parse(
      '$baseUrl/admin/tournament/$tournamentId/match/$matchId/stream',
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'isStreaming': isStreaming,
        'streamKey': streamKey,
        'hlsUrl': hlsUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update stream: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}