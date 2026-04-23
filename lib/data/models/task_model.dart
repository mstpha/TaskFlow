// lib/data/models/task_model.dart
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String projectId;
  final String createdBy;
  final String? assignedTo;
  final String status; // Todo, In Progress, Review, Done
  final String priority; // Low, Medium, High, Critical
  final DateTime? dueDate;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.projectId,
    required this.createdBy,
    this.assignedTo,
    this.status = 'Todo',
    this.priority = 'Medium',
    this.dueDate,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        projectId: json['project_id'],
        createdBy: json['created_by'],
        assignedTo: json['assigned_to'],
        status: json['status'] ?? 'Todo',
        priority: json['priority'] ?? 'Medium',
        dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'project_id': projectId,
        'created_by': createdBy,
        'assigned_to': assignedTo,
        'status': status,
        'priority': priority,
        'due_date': dueDate?.toIso8601String(),
      };

  TaskModel copyWith({
    String? title,
    String? description,
    String? assignedTo,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) =>
      TaskModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        projectId: projectId,
        createdBy: createdBy,
        assignedTo: assignedTo ?? this.assignedTo,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt,
      );
}
