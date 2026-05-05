class TeamMember {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? phone;
  final bool isActive;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.phone,
    this.isActive = true,
  });
}