class TournamentModel {
  final String tournamentId;
  final String name;
  final String sport;
  final String mode;

  TournamentModel({
    required this.tournamentId,
    required this.name,
    required this.sport,
    required this.mode,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      tournamentId: json['tournament_id'],
      name: json['name'],
      sport: json['sport'],
      mode: json['mode'],
    );
  }
}
