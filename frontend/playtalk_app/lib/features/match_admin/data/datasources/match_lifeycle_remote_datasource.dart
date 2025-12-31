import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
class MatchLifecycleRemoteDatasource {
  final String baseUrl;
  final String adminId;

  MatchLifecycleRemoteDatasource({
    required this.baseUrl,
    required this.adminId,
  });

  Future<void> startMatch(String matchId, {required String tournamentId}) async {
    print("Starting match with ID: $matchId");
    final response = await http.post(
      Uri.parse("$baseUrl/admin/match/$matchId/start"),
      headers: {
        "x-admin-id": adminId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to start match");
    }
  }

  Future<void> endMatch({
  required String matchId,
  required String tournamentId,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/admin/match/$matchId/end"),
    headers: {
      "x-admin-id": adminId,
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "tournamentId": tournamentId,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to end match");
  }
}

}


// import 'package:dio/dio.dart';

// class MatchLifecycleRemoteDatasource {
//   final Dio dio;
//   final String adminId;

//   MatchLifecycleRemoteDatasource({
//     required String baseUrl,
//     required this.adminId,
//   }) : dio = Dio(BaseOptions(baseUrl: baseUrl));

//   Future<void> startMatch({
//     required String tournamentId,
//     required String matchId,
//   }) async {
//     await dio.post(
//       "/admin/match/$matchId/end",
//       options: Options(
//         headers: {
//           "x-admin-id": adminId,
//         },
//       ),
//     );
//   }
// }
