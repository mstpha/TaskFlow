// lib/data/models/profile_model.dart
class ProfileModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'],
        email: json['email'] ?? '',
        fullName: json['full_name'],
        avatarUrl: json['avatar_url'],
      );

  String get displayName => fullName ?? email.split('@').first;
}
