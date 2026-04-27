/// Interfaz abstracta del repositorio de perfil.
import 'package:flash_app/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String userId);
  Future<void> updateProfile(String userId, {String? fullName, String? phone});
}