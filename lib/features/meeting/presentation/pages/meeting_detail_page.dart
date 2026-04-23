import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../controllers/meetings_controller.dart';
import '../theme/app_colors.dart';

class MeetingDetailPage extends GetView<MeetingsController> {
  const MeetingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          Obx(() {
            final meeting = controller.selectedMeeting.value;
            if (meeting == null || meeting.status != 'done') {
              return const SizedBox();
            }
            return IconButton(
              onPressed: () => _exportPdf(meeting),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              tooltip: 'Exporter en PDF',
            );
          }),
        ],
      ),
      body: Obx(() {
        final meeting = controller.selectedMeeting.value;
        final isLoading = controller.isLoading.value;

        if (isLoading && meeting == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (meeting != null &&
            (meeting.status == 'pending' || meeting.status == 'processing')) {
          return _buildProcessingView(meeting.status);
        }

        if (meeting != null && meeting.status == 'failed') {
          return _buildErrorView(meeting.summary);
        }

        if (meeting == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildResultView(meeting, context);
      }),
    );
  }

  // ── Export PDF ────────────────────────────────────────────────────
  Future<void> _exportPdf(meeting) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // ── En-tête ──
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('1a1a6e'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'COMPTE-RENDU DE RÉUNION',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  meeting.title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${meeting.createdAt.day}/${meeting.createdAt.month}/${meeting.createdAt.year} à ${meeting.createdAt.hour.toString().padLeft(2, '0')}h${meeting.createdAt.minute.toString().padLeft(2, '0')}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // ── Résumé ──
          _pdfSection(
            title: 'RÉSUMÉ',
            color: PdfColor.fromHex('1a1a6e'),
            child: pw.Text(
              meeting.summary ?? 'Aucun résumé disponible.',
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
            ),
          ),

          pw.SizedBox(height: 16),

          // ── Décisions ──
          _pdfSection(
            title: 'DÉCISIONS (${meeting.decisions.length})',
            color: PdfColor.fromHex('7C3AED'),
            child: meeting.decisions.isEmpty
                ? pw.Text('Aucune décision.',
                    style: const pw.TextStyle(fontSize: 11))
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: meeting.decisions
                        .map<pw.Widget>((d) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Row(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    margin: const pw.EdgeInsets.only(
                                        top: 5, right: 8),
                                    width: 5,
                                    height: 5,
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColor.fromInt(0xFF7C3AED),
                                      shape: pw.BoxShape.circle,
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Text(d.toString(),
                                        style: const pw.TextStyle(
                                            fontSize: 11, lineSpacing: 3)),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ),

          pw.SizedBox(height: 16),

          // ── Tâches ──
          _pdfSection(
            title: 'TÂCHES (${meeting.tasks.length})',
            color: PdfColor.fromHex('059669'),
            child: meeting.tasks.isEmpty
                ? pw.Text('Aucune tâche.',
                    style: const pw.TextStyle(fontSize: 11))
                : pw.Column(
                    children: meeting.tasks.map<pw.Widget>((task) {
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.grey300, width: 0.5),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 16,
                              height: 16,
                              margin: const pw.EdgeInsets.only(right: 10),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColor.fromHex('059669'),
                                    width: 1.5),
                                borderRadius: pw.BorderRadius.circular(3),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(task.action,
                                      style: pw.TextStyle(
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold)),
                                  pw.SizedBox(height: 2),
                                  pw.Text('👤 ${task.assignee}',
                                      style: const pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColors.grey600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          pw.SizedBox(height: 32),

          // ── Pied de page ──
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Text(
            'Généré par MindScribe AI — ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: const pw.TextStyle(
                fontSize: 9, color: PdfColors.grey500),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${meeting.title}.pdf',
    );
  }

  pw.Widget _pdfSection({
    required String title,
    required PdfColor color,
    required pw.Widget child,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 3,
                height: 14,
                color: color,
                margin: const pw.EdgeInsets.only(right: 8),
              ),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          child,
        ],
      ),
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
              style:
                  TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
          // En-tête
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
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // Bouton export PDF
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _exportPdf(meeting),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Exporter en PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Résumé
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

          // Décisions
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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

          // Tâches
          _buildSection(
            icon: Icons.task_alt_rounded,
            title: 'Tâches (${meeting.tasks.length})',
            color: const Color(0xFF059669),
            child: meeting.tasks.isEmpty
                ? Text('Aucune tâche.',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary))
                : Column(
                    children:
                        List.generate(meeting.tasks.length, (index) {
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