import '../repositories/meeting_repository.dart';

class InviteParticipants {
  final MeetingRepository repository;
  const InviteParticipants(this.repository);

  Future<void> call({
    required int meetingId,
    required List<int> memberIds,
  }) =>
      repository.inviteParticipants(
        meetingId: meetingId,
        memberIds: memberIds,
      );
}