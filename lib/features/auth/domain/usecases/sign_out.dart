/// Caso de uso: Cerrar sesión.
import 'package:flash_app/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}