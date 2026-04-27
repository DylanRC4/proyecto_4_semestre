/// Caso de uso: Actualizar perfil del usuario.
import 'package:flash_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<void> call(String userId, {String? fullName, String? phone}) async {
    return await repository.updateProfile(userId, fullName: fullName, phone: phone);
  }
}