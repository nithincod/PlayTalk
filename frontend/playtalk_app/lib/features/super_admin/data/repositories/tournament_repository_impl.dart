import '../../domain/models/tournament_model.dart';
import '../datasources/tournament_remote_datasource.dart';

class TournamentRepositoryImpl {
  final TournamentRemoteDatasource datasource;

  TournamentRepositoryImpl(this.datasource);

  Future<List<TournamentModel>> getTournaments() async {
    final rawList = await datasource.fetchTournaments();

    return rawList
        .map(
          (e) => TournamentModel(
            id: e['tournament_id'],
            name: e['name'],
            sport: e['sport'],
            mode: e['mode'],
          ),
        )
        .toList();
  }

  Future<void> createTournament({
  required String name,
  required String sport,
  required String mode,
}) {
  return datasource.createTournament(
    name: name,
    sport: sport,
    mode: mode,
  );
}

}
