import 'task.dart';

class Meeting {
  final int? id;
  final String title;
  final String? audioPath;
  final String? transcription;
  final String? summary;
  final List<String> decisions;
  final List<Task> tasks;
  final DateTime createdAt;
  final String status; // 'pending', 'processing', 'done'

  const Meeting({
    this.id,
    required this.title,
    this.audioPath,
    this.transcription,
    this.summary,
    this.decisions = const [],
    this.tasks = const [],
    required this.createdAt,
    this.status = 'pending',
  });
}