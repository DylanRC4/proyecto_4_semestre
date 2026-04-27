/// Fuente de datos remota de autenticación (Supabase Auth).
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasource(this._client);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  bool get isAuthenticated => _client.auth.currentSession != null;

  String? get currentUserEmail => _client.auth.currentUser?.email;
}