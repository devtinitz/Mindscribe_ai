import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    super.id,
    required super.assignee,
    required super.action,
    super.isDone,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int?,
      assignee: (json['assignee'] ?? '') as String,
      action: (json['action'] ?? '') as String,
      isDone: (json['is_done'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignee': assignee,
      'action': action,
      'is_done': isDone,
    };
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      assignee: task.assignee,
      action: task.action,
      isDone: task.isDone,
    );
  }
}
