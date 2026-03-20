import 'package:equatable/equatable.dart';

class MatchAdminUserModel extends Equatable {
  final String adminId;
  final String name;
  final String role;
  final String email;

  const MatchAdminUserModel({
    required this.adminId,
    required this.name,
    required this.role,
    required this.email,
  });

  factory MatchAdminUserModel.fromJson(Map<String, dynamic> json) {
    return MatchAdminUserModel(
      adminId: json['adminId'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'match_admin',
      email: json['email'] ?? '',
    );
  }

  @override
  List<Object?> get props => [adminId, name, role, email];
}