class AppSession {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String approvalStatus;
  final String collegeId;
  final String token;

  AppSession({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.approvalStatus,
    required this.collegeId,
    required this.token,
  });

  bool get isApproved => approvalStatus.toLowerCase() == "approved";

  bool get isSuperAdmin => role.toLowerCase() == "super_admin";

  bool get isMatchAdmin => role.toLowerCase() == "match_admin";

  bool get isUser => role.toLowerCase() == "user";
}