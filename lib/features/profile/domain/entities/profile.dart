/// Entidad de dominio: Perfil de usuario.
class ProfileEntity {
  final String id;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  const ProfileEntity({
    required this.id,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  ProfileEntity copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) {
    return ProfileEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }
}