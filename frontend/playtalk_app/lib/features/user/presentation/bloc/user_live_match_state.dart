class UserLiveMatchState {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? match;

  const UserLiveMatchState({
    this.loading = false,
    this.error,
    this.match,
  });

  UserLiveMatchState copyWith({
    bool? loading,
    String? error,
    Map<String, dynamic>? match,
    bool clearError = false,
  }) {
    return UserLiveMatchState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      match: match ?? this.match,
    );
  }
}