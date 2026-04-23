import '../entities/meeting.dart';

abstract class MeetingRepository {
  Future<Meeting> uploadMeetingAudio({
    required String audioFilePath,
    required String title,
  });

  Future<Meeting> getMeetingDetails(int meetingId);

  Future<List<Meeting>> getMeetings();

  Future<List<Meeting>> searchMeetings(String query);
}
