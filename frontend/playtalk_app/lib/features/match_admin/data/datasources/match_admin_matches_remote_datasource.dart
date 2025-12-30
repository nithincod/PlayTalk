import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:playtalk_app/features/match_admin/domain/models/match_model.dart';



class AdminMatchesRemoteDatasource {
  final String baseUrl;

  AdminMatchesRemoteDatasource(this.baseUrl);

  Future<List<MatchModel>> getAssignedMatches(String adminId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/assigned-matches"), // ✅ FIXED
      headers: {
        "Content-Type": "application/json",
        "x-admin-id": adminId, // ✅ REQUIRED
      },
    );

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load assigned matches");
    }

    final List data = jsonDecode(response.body);

   for (final m in data) {
  print("RAW JSON STATUS: ${m['status']}");
   }


    // final List<dynamic> data2 = jsonDecode(response.body);

    return data.map((json) {
      return MatchModel(
        matchId: json['matchId'],
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
