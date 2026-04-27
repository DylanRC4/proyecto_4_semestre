/// Caso de uso: Iniciar sesión.
import 'package:flash_app/features/auth/domain/repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<void> call({
    required String email,
    required String password,
  }) async {
    return await repository.signIn(email: email, password: password);
  }
}