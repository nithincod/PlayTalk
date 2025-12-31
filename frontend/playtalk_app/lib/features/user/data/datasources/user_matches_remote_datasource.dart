import 'package:firebase_database/firebase_database.dart';
import '../../domain/models/match_model.dart';

class UserMatchesRemoteDatasource {
  Stream<List<MatchModel>> listenAllMatches({
    required String collegeId,
  }) {
    final ref = FirebaseDatabase.instance.ref("tournaments/$collegeId");

    return ref.onValue.map((event) {
      final List<MatchModel> matches = [];

      final data = event.snapshot.value;
      if (data == null) return matches;

      final tournaments = Map<String, dynamic>.from(data as Map);

      for (final tournamentId in tournaments.keys) {
        final tournament = tournaments[tournamentId];
        if (tournament['matches'] == null) continue;

        final matchesMap =
            Map<String, dynamic>.from(tournament['matches']);

        for (final matchId in matchesMap.keys) {
          final match =
              Map<String, dynamic>.from(matchesMap[matchId]);

          matches.add(
            MatchModel.fromJson({
              ...match,
              "matchId": matchId,
              "tournamentId": tournamentId,
            }),
          );
        }
      }

      return matches;
    });
  }
}
