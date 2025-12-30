import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class LiveMatchRemoteDatasource {
  Stream<Map<String, dynamic>> listenMatch(
  String collegeId,
  String tournamentId,
  String matchId,
) {
  final ref = FirebaseDatabase.instance.ref(
    "tournaments/$collegeId/$tournamentId/matches/$matchId",
  );

  return ref.onValue.map((event) {
    final raw = event.snapshot.value as Map<dynamic, dynamic>;

    final match = Map<String, dynamic>.from(raw);

    final score = raw['score'] != null
        ? Map<String, dynamic>.from(raw['score'])
        : <String, dynamic>{};

    final events = raw['events'] != null
        ? (raw['events'] as Map<dynamic, dynamic>)
            .values
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    return {
      "match": match,
      "score": score,
      "events": events,
    };
  });
}


}
