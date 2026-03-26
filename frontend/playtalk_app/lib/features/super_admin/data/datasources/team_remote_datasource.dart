import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/models/team_model.dart';

class TeamRemoteDatasource {
  final String baseUrl;
  final String token;

  TeamRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<List<TeamModel>> fetchTeams(String tournamentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/superadmin/tournament/$tournamentId/teams'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("FETCH TEAMS STATUS: ${response.statusCode}");
    print("FETCH TEAMS BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch teams");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception("Invalid teams response format");
    }

    return decoded
        .map<TeamModel>(
          (e) => TeamModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<void> createTeam({
    required String tournamentId,
    required String name,
    required String sport,
    required List<String> players,
    required String captain,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/superadmin/tournament/$tournamentId/team'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'sport': sport,
        'players': players,
        'captain': captain,
      }),
    );

    print("CREATE TEAM STATUS: ${response.statusCode}");
    print("CREATE TEAM BODY: ${response.body}");

    if (response.statusCode != 201) {
      throw Exception("Failed to create team");
    }
  }

  Future<void> deleteTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/superadmin/tournament/$tournamentId/team/$teamId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("DELETE TEAM STATUS: ${response.statusCode}");
    print("DELETE TEAM BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to delete team");
    }
  }
}