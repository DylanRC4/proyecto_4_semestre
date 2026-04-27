/// Modelo de perfil. Convierte JSON ↔ entidad Profile.
import 'package:flash_app/features/profile/domain/entities/profile.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    super.phone,
    super.avatarUrl,
    required super.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }
}