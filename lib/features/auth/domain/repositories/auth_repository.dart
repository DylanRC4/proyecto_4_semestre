/// Interfaz abstracta del repositorio de autenticación.
abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  Future<void> signOut();
  bool get isAuthenticated;
  String? get currentUserEmail;
}