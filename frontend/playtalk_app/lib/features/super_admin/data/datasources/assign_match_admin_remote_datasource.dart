import 'package:dio/dio.dart';

class AssignMatchAdminRemoteDatasource {
  final Dio dio;
  final String baseUrl;
  final String superAdminId;

  AssignMatchAdminRemoteDatasource({
    required this.baseUrl,
    required this.superAdminId,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {
              "Content-Type": "application/json",
            },
          ),
        );

  /// ✅ ASSIGN ADMIN TO MATCH (TOURNAMENT-CENTRIC)
  Future<void> assignAdmin({
    required String tournamentId,
    required String matchId,
    required String adminId,
    required String adminName,
  }) async {
    await dio.post(
      "/admin/tournament/$tournamentId/match/$matchId/assign-admin",
      options: Options(
        headers: {
          "x-admin-id": superAdminId, // 🔐 auth
        },
      ),
      data: {
        "adminId": adminId,
        "adminName": adminName,
      },
    );
  }
}
