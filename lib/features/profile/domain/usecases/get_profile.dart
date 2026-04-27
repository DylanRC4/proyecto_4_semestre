/// Caso de uso: Obtener perfil del usuario.
import 'package:flash_app/features/profile/domain/entities/profile.dart';
import 'package:flash_app/features/profile/domain/repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<ProfileEntity> call(String userId) async {
    return await repository.getProfile(userId);
  }
}