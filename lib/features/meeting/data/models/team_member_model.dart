import 'package:mindscribe_app/features/meeting/domain/entities/team_member.dart';

class TeamMemberModel extends TeamMember {
  const TeamMemberModel({
    required super.id,
    required super.name,
    required super.email,
    super.role,
    super.phone,
    super.isActive,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}