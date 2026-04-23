import '../../domain/entities/meeting.dart';
import 'task_model.dart';

class MeetingModel extends Meeting {
  const MeetingModel({
    super.id,
    required super.title,
    super.audioPath,
    super.transcription,
    super.summary,
    super.decisions,
    super.tasks,
    required super.createdAt,
    super.status,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    final tasksJson = (json['tasks'] as List<dynamic>? ?? []);
    return MeetingModel(
      id: json['id'] as int?,
      title: (json['title'] ?? 'Sans titre') as String,
      audioPath: json['audio_path'] as String?,
      transcription: json['transcription'] as String?,
      summary: json['summary'] as String?,
      decisions: (json['decisions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      tasks: tasksJson
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '') as String) ??
          DateTime.now(),
      status: (json['status'] ?? 'pending') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'audio_path': audioPath,
      'transcription': transcription,
      'summary': summary,
      'decisions': decisions,
      'tasks': tasks.map(TaskModel.fromEntity).map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory MeetingModel.fromEntity(Meeting meeting) {
    return MeetingModel(
      id: meeting.id,
      title: meeting.title,
      audioPath: meeting.audioPath,
      transcription: meeting.transcription,
      summary: meeting.summary,
      decisions: meeting.decisions,
      tasks: meeting.tasks,
      createdAt: meeting.createdAt,
      status: meeting.status,
    );
  }
}
