import '../../data/repositories/tournament_repository_impl.dart';

class CreateTournament {
  final TournamentRepositoryImpl repository;

  CreateTournament(this.repository);

  Future<void> call({
    required String name,
    required String sport,
    required String mode,
  }) {
    return repository.createTournament(
      name: name,
      sport: sport,
      mode: mode,
    );
  }
}
