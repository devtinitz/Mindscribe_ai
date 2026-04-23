import '../entities/meeting.dart';
import '../repositories/meeting_repository.dart';

class UploadMeetingAudio {
  final MeetingRepository repository;

  const UploadMeetingAudio(this.repository);

  Future<Meeting> call({
    required String audioFilePath,
    required String title,
  }) {
    return repository.uploadMeetingAudio(
      audioFilePath: audioFilePath,
      title: title,
    );
  }
}
