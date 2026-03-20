import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:playtalk_app/features/user/domain/models/user_match_model.dart';

class UserMatchesRemoteDatasource {
  final String baseUrl;
  final String token;

  UserMatchesRemoteDatasource({
    required this.baseUrl,
    required this.token,
  });

  Future<List<UserMatchModel>> fetchUserMatches() async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/matches"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("USER MATCHES STATUS: ${response.statusCode}");
    print("USER MATCHES BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to load user matches");
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((json) => UserMatchModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}