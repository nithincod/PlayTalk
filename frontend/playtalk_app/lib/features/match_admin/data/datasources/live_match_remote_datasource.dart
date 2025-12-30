import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class LiveMatchRemoteDatasource {
  Stream<Map<String, dynamic>> listenMatch(
    String tournamentId,
    String matchId,
  ) {
    final ref = FirebaseDatabase.instance.ref(
      "tournaments/$tournamentId/matches/$matchId",
    );

    return ref.onValue.map((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      return {
        "match": data,
        "score": data["score"] ?? {},
        "events": data["events"] != null
            ? Map<String, dynamic>.from(data["events"]).values.toList()
            : [],
      };
    });
  }
}
