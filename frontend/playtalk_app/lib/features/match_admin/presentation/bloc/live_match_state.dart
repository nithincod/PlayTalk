abstract class LiveMatchState {}

class LiveMatchLoading extends LiveMatchState {}

class LiveMatchUpdated extends LiveMatchState {
  final Map<String, dynamic> match;
  final Map<String, dynamic> score;
  final List<dynamic> events;

  LiveMatchUpdated({
    required this.match,
    required this.score,
    required this.events,
  });
}

class LiveMatchError extends LiveMatchState {
  final String message;
  LiveMatchError(this.message);
}
