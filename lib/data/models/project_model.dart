// lib/data/models/project_model.dart
class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String color;
  final List<String> memberIds;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.color = '#6366F1',
    this.memberIds = const [],
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        ownerId: json['owner_id'],
        color: json['color'] ?? '#6366F1',
        memberIds: List<String>.from(json['member_ids'] ?? []),
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'owner_id': ownerId,
        'color': color,
        'member_ids': memberIds,
      };
}
