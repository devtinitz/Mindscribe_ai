import '../../domain/entities/meeting.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/repositories/meeting_repository.dart';
import '../datasources/remote/meeting_remote_data_source.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  const MeetingRepositoryImpl(this._remoteDataSource);

  final MeetingRemoteDataSource _remoteDataSource;

  @override
  Future<Meeting> getMeetingDetails(int meetingId) {
    return _remoteDataSource.getMeetingDetails(meetingId);
  }

  @override
  Future<List<Meeting>> getMeetings() {
    return _remoteDataSource.getMeetings();
  }

  @override
  Future<List<Meeting>> searchMeetings(String query) {
    return _remoteDataSource.searchMeetings(query);
  }

  @override
  Future<Meeting> uploadMeetingAudio({
    required String audioFilePath,
    required String title,
  }) {
    return _remoteDataSource.uploadMeetingAudio(
      audioFilePath: audioFilePath,
      title: title,
    );
  }

  @override
  Future<List<TeamMember>> getTeamMembers() async {
    final models = await _remoteDataSource.getTeamMembers();
    return models.cast<TeamMember>();
  }

  @override
  Future<void> inviteParticipants({
    required int meetingId,
    required List<int> memberIds,
  }) {
    return _remoteDataSource.inviteParticipants(
      meetingId: meetingId,
      memberIds: memberIds,
    );
  }
}