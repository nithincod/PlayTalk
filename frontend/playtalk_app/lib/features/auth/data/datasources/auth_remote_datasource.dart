import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  final String baseUrl;

  AuthRemoteDatasource({
    required this.baseUrl,
  });

  Future<Map<String, dynamic>> registerProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? collegeId,
    String? designation,
    String? coordinatorIdNumber,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register-profile"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "uid": uid,
        "name": name,
        "email": email,
        "role": role,
        "collegeId": collegeId,
        "designation": designation,
        "coordinatorIdNumber": coordinatorIdNumber,
        "phone": phone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to register profile: ${response.statusCode} ${response.body}",
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCurrentProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/auth/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to fetch current profile: ${response.statusCode} ${response.body}",
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // If backend returns { profile: {...} }, extract it
    if (data.containsKey("profile") && data["profile"] is Map<String, dynamic>) {
      return data["profile"] as Map<String, dynamic>;
    }

    // If backend returns profile directly
    return data;
  }
}