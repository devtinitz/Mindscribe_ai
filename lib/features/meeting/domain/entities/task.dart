class Task {
  final int? id;
  final String assignee; // Nom de la personne
  final String action;   // Ce qu'elle doit faire
  final bool isDone;

  const Task({
    this.id,
    required this.assignee,
    required this.action,
    this.isDone = false,
  });
}