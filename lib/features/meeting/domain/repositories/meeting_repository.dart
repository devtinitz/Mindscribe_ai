import '../entities/meeting.dart';
import '../entities/team_member.dart';

abstract class MeetingRepository {
  Future<Meeting> uploadMeetingAudio({
    required String audioFilePath,
    required String title,
  });

  Future<Meeting> getMeetingDetails(int meetingId);

  Future<List<Meeting>> getMeetings();

  Future<List<Meeting>> searchMeetings(String query);

  Future<List<TeamMember>> getTeamMembers();

  Future<void> inviteParticipants({
    required int meetingId,
    required List<int> memberIds,
  });
}