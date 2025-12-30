abstract class MatchEventState {}

class MatchEventInitial extends MatchEventState {}

class MatchEventLoading extends MatchEventState {}

class MatchEventSuccess extends MatchEventState {}

class MatchEventFailure extends MatchEventState {
  final String message;
  MatchEventFailure(this.message);
}
