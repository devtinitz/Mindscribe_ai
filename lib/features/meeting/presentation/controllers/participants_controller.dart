import 'package:get/get.dart';

import '../../domain/entities/team_member.dart';
import '../../domain/usecases/get_team_members.dart';
import '../../domain/usecases/invite_participants.dart';

class ParticipantsController extends GetxController {
  ParticipantsController({
    required GetTeamMembers getTeamMembers,
    required InviteParticipants inviteParticipants,
  })  : _getTeamMembers = getTeamMembers,
        _inviteParticipants = inviteParticipants;

  final GetTeamMembers _getTeamMembers;
  final InviteParticipants _inviteParticipants;

  final members = <TeamMember>[].obs;
  final selectedIds = <int>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers() async {
    isLoading.value = true;
    try {
      final result = await _getTeamMembers();
      members.assignAll(result);
    } catch (e) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMember(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  bool isSelected(int id) => selectedIds.contains(id);

  // Appelé après l'upload pour envoyer les invitations
  Future<void> sendInvitations(int meetingId) async {
    if (selectedIds.isEmpty) return;
    isSending.value = true;
    try {
      await _inviteParticipants(
        meetingId: meetingId,
        memberIds: selectedIds.toList(),
      );
      Get.snackbar(
        '✅ Invitations envoyées !',
        '${selectedIds.length} participant(s) notifié(s) par email.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      selectedIds.clear();
    } catch (e) {
      // ignore silently
    } finally {
      isSending.value = false;
    }
  }
}