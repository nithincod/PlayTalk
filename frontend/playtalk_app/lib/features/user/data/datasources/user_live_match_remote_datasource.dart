import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class UserLiveMatchRemoteDatasource {
  Stream<Map<String, dynamic>> watchMatch({
    required String collegeId,
    required String tournamentId,
    required String matchId,
  }) {
    final ref = FirebaseDatabase.instance
        .ref("tournaments/$collegeId/$tournamentId/matches/$matchId");

    return ref.onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) {
        throw Exception("Match not found");
      }

      return Map<String, dynamic>.from(data as Map);
    });
  }
}