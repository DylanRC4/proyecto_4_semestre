/// Implementación del repositorio de autenticación.
import 'package:flash_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flash_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    return await remoteDatasource.signIn(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await remoteDatasource.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  @override
  Future<void> signOut() async {
    return await remoteDatasource.signOut();
  }

  @override
  bool get isAuthenticated => remoteDatasource.isAuthenticated;

  @override
  String? get currentUserEmail => remoteDatasource.currentUserEmail;
}