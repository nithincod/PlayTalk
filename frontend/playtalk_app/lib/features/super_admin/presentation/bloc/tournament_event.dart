abstract class TournamentEvent {}

class LoadTournaments extends TournamentEvent {}

class CreateTournamentEvent extends TournamentEvent {
  final String name;
  final String sport;
  final String mode;

  CreateTournamentEvent({
    required this.name,
    required this.sport,
    required this.mode,
  });
}

