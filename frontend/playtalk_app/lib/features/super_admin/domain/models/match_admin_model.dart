class MatchAdminModel {
  final String adminId;
  final String name;
  final String role;

  MatchAdminModel({
    required this.adminId,
    required this.name,
    required this.role,
  });

  factory MatchAdminModel.fromJson(Map<String, dynamic> json) {
    return MatchAdminModel(
      adminId: json["adminId"],
      name: json["name"],
      role: json["role"],
    );
  }
}
