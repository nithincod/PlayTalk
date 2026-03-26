import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/models/tournament_summary_model.dart';

class TournamentSummaryRemoteDatasource {
  final String baseUrl;
  final String token;

  TournamentSummaryRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<TournamentSummaryModel> fetchSummary(String tournamentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/superadmin/tournament/$tournamentId/summary'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("TOURNAMENT SUMMARY STATUS: ${response.statusCode}");
    print("TOURNAMENT SUMMARY BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch tournament summary");
    }

    final decoded = jsonDecode(response.body);
    return TournamentSummaryModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }
}