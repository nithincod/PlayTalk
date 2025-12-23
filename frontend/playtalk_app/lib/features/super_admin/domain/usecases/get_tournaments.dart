import '../models/tournament_model.dart';
import '../../data/repositories/tournament_repository_impl.dart';

class GetTournaments {
  final TournamentRepositoryImpl repository;

  GetTournaments(this.repository);

  Future<List<TournamentModel>> call() {
    return repository.getTournaments();
  }
}
