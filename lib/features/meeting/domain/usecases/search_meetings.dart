import '../entities/meeting.dart';
import '../repositories/meeting_repository.dart';

class SearchMeetings {
  final MeetingRepository repository;

  const SearchMeetings(this.repository);

  Future<List<Meeting>> call(String query) {
    return repository.searchMeetings(query);
  }
}
