class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String category;
  final String priority; // 'High', 'Medium', 'Low'
  final bool isCompleted;
  final List<String> subtasks;
  final List<bool> subtaskDone;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.priority,
    required this.isCompleted,
    this.subtasks = const [],
    List<bool>? subtaskDone,
  }) : subtaskDone = subtaskDone ?? List.filled(subtasks.length, false);

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final subtasks =
        (json['subtasks'] as List?)?.map((e) => e as String).toList() ?? [];
    List<bool> subtaskDone =
        (json['subtaskDone'] as List?)?.map((e) => e as bool).toList() ?? [];
    // Pastikan panjang subtaskDone sama dengan subtasks
    if (subtaskDone.length < subtasks.length) {
      subtaskDone = List<bool>.from(subtaskDone)
        ..addAll(List.filled(subtasks.length - subtaskDone.length, false));
    }
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      category: json['category'] as String,
      priority: json['priority'] as String,
      isCompleted: json['isCompleted'] as bool,
      subtasks: subtasks,
      subtaskDone: subtaskDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
      'subtasks': subtasks,
      'subtaskDone': subtaskDone,
    };
  }
}
