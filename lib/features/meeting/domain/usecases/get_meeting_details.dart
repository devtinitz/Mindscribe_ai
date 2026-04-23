import '../entities/meeting.dart';
import '../repositories/meeting_repository.dart';

class GetMeetingDetails {
  final MeetingRepository repository;

  const GetMeetingDetails(this.repository);

  Future<Meeting> call(int meetingId) {
    return repository.getMeetingDetails(meetingId);
  }
}
