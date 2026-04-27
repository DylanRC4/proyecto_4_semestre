/// Implementación del repositorio de perfil.
import 'package:flash_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flash_app/features/profile/data/models/profile_model.dart';
import 'package:flash_app/features/profile/domain/entities/profile.dart';
import 'package:flash_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepositoryImpl(this.remoteDatasource);

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    final data = await remoteDatasource.getProfile(userId);
    return ProfileModel.fromJson(data);
  }

  @override
  Future<void> updateProfile(String userId, {String? fullName, String? phone}) async {
    return await remoteDatasource.updateProfile(userId, fullName: fullName, phone: phone);
  }
}