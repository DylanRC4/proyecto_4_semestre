/// Caso de uso: Registrar nuevo usuario.
import 'package:flash_app/features/auth/domain/repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<void> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}