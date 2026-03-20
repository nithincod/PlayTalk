import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:playtalk_app/features/match_admin/domain/models/match_admin_model.dart';

class AdminMatchesRemoteDatasource {
  final String baseUrl;
  final String token;

  AdminMatchesRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<List<MatchAdminModel>> getAssignedMatches() async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/assigned-matches"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load assigned matches");
    }

    final List data = jsonDecode(response.body);

    return data.map((json) {
      return MatchAdminModel(
        matchId: json['matchId'],
        collegeId: json['collegeId'],
        name: json['name'],
        teamA: json['teamA'],
        teamB: json['teamB'],
        matchType: json['matchType'],
        court: json['court'],
        tournamentId: json['tournamentId'],
        status: json['status'] ?? 'upcoming',
        sport: json['sport'] ?? '',
      );
    }).toList();
  }
}