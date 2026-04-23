import '../entities/meeting.dart';
import '../repositories/meeting_repository.dart';

class GetMeetings {
  final MeetingRepository repository;

  const GetMeetings(this.repository);

  Future<List<Meeting>> call() {
    return repository.getMeetings();
  }
}
