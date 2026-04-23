import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meetings_controller.dart';
import '../theme/app_colors.dart';

class MeetingDetailPage extends GetView<MeetingsController> {
  const MeetingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Charge le détail dès l'ouverture de la page ──
    final meetingId = Get.arguments as int?;
    if (meetingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadMeetingDetail(meetingId);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compte-rendu'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Obx(() {
        final meeting = controller.selectedMeeting.value;
        final isLoading = controller.isLoading.value;

        // ── Chargement initial ──
        if (isLoading && meeting == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // ── Traitement en cours (pending / processing) ──
        if (meeting != null &&
            (meeting.status == 'pending' || meeting.status == 'processing')) {
          return _buildProcessingView(meeting.status);
        }

        // ── Erreur ──
        if (meeting != null && meeting.status == 'failed') {
          return _buildErrorView(meeting.summary);
        }

        // ── Aucun résultat ──
        if (meeting == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // ── Résultat complet ──
        return _buildResultView(meeting, context);
      }),
    );
  }

  // ── Vue traitement en cours ───────────────────────────────────────
  Widget _buildProcessingView(String status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              status == 'pending'
                  ? '⏳ En attente de traitement...'
                  : '🧠 L\'IA analyse votre réunion...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Transcription + analyse en cours.\nCela peut prendre 1 à 2 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            // Étapes visuelles
            _buildStep('🎙️', 'Audio reçu', true),
            _buildStep('📝', 'Transcription Whisper', status == 'processing'),
            _buildStep('🤖', 'Analyse GPT-4o', false),
            _buildStep('✅', 'Compte-rendu généré', false),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String emoji, String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppColors.primary : AppColors.hint,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ]
        ],
      ),
    );
  }

  // ── Vue erreur ────────────────────────────────────────────────────
  Widget _buildErrorView(String? backendMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  color: AppColors.danger, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Une erreur est survenue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              (backendMessage != null && backendMessage.trim().isNotEmpty)
                  ? backendMessage
                  : 'L\'IA n\'a pas pu traiter cet enregistrement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Vue résultat complet ──────────────────────────────────────────
  Widget _buildResultView(meeting, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ──
          Text(
            meeting.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${meeting.createdAt.day}/${meeting.createdAt.month}/${meeting.createdAt.year} à ${meeting.createdAt.hour.toString().padLeft(2, '0')}h${meeting.createdAt.minute.toString().padLeft(2, '0')}',
            style:
                TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // ── Résumé ──
          _buildSection(
            icon: Icons.summarize_rounded,
            title: 'Résumé',
            color: AppColors.primary,
            child: Text(
              meeting.summary ?? 'Pas de résumé disponible.',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),

          const SizedBox(height: 16),

          // ── Décisions ──
          _buildSection(
            icon: Icons.gavel_rounded,
            title: 'Décisions (${meeting.decisions.length})',
            color: const Color(0xFF7C3AED),
            child: meeting.decisions.isEmpty
                ? Text('Aucune décision.',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meeting.decisions
                        .map<Widget>((d) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 7),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF7C3AED),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(d.toString(),
                                        style: const TextStyle(
                                            fontSize: 14, height: 1.5)),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ),

          const SizedBox(height: 16),

          // ── Tâches ──
          _buildSection(
            icon: Icons.task_alt_rounded,
            title: 'Tâches (${meeting.tasks.length})',
            color: const Color(0xFF059669),
            child: meeting.tasks.isEmpty
                ? Text('Aucune tâche.',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary))
                : Column(
                    children: List.generate(meeting.tasks.length, (index) {
                      final task = meeting.tasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: CheckboxListTile(
                          value: task.isDone,
                          onChanged: (_) =>
                              controller.toggleTaskDone(index),
                          activeColor: const Color(0xFF059669),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            task.action,
                            style: TextStyle(
                              fontSize: 14,
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '👤 ${task.assignee}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Section réutilisable ──────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}