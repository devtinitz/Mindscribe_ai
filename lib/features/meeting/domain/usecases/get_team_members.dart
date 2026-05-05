import '../entities/team_member.dart';
import '../repositories/meeting_repository.dart';

class GetTeamMembers {
  final MeetingRepository repository;
  const GetTeamMembers(this.repository);

  Future<List<TeamMember>> call() => repository.getTeamMembers();
}