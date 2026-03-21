import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/models/match_admin_model.dart';

class AdminMatchesRemoteDatasource {
  final String baseUrl;
  final String token;

  AdminMatchesRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<List<MatchAdminModel>> getAssignedMatches() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/assigned-matches'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("ASSIGNED MATCHES STATUS: ${response.statusCode}");
    print("ASSIGNED MATCHES BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch assigned matches');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid response format for assigned matches');
    }

    return decoded
        .map<MatchAdminModel>((item) {
          return MatchAdminModel.fromJson(
            Map<String, dynamic>.from(item),
          );
        })
        .toList();
  }
}