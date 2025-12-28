abstract class MatchLifecycleState {}

class MatchLifecycleInitial extends MatchLifecycleState {}

class MatchLifecycleLoading extends MatchLifecycleState {}

class MatchLifecycleSuccess extends MatchLifecycleState {}

class MatchLifecycleFailure extends MatchLifecycleState {
  final String message;
  MatchLifecycleFailure(this.message);
}
