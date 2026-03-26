import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/models/bracket_match_model.dart';

class BracketRemoteDatasource {
  final String baseUrl;
  final String token;

  BracketRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<List<BracketMatchModel>> fetchBracket(String tournamentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/superadmin/tournament/$tournamentId/bracket'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("FETCH BRACKET STATUS: ${response.statusCode}");
    print("FETCH BRACKET BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch bracket");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception("Invalid bracket response");
    }

    return decoded
        .map<BracketMatchModel>(
          (e) => BracketMatchModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<void> generateBracket(String tournamentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/superadmin/tournament/$tournamentId/generate-bracket'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("GENERATE BRACKET STATUS: ${response.statusCode}");
    print("GENERATE BRACKET BODY: ${response.body}");

    if (response.statusCode != 201) {
      throw Exception("Failed to generate bracket");
    }
  }
}