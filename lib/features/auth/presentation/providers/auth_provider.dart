/// Proveedor de autenticación (Riverpod).
/// Gestiona login, registro y logout usando casos de uso del dominio.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flash_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flash_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flash_app/features/auth/domain/usecases/sign_in.dart';
import 'package:flash_app/features/auth/domain/usecases/sign_up.dart';
import 'package:flash_app/features/auth/domain/usecases/sign_out.dart';

// Proveedores internos de inyección de dependencias
final _authDatasourceProvider = Provider(
  (ref) => AuthRemoteDatasource(Supabase.instance.client),
);
final _authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(ref.read(_authDatasourceProvider)),
);
final _signInProvider = Provider((ref) => SignIn(ref.read(_authRepositoryProvider)));
final _signUpProvider = Provider((ref) => SignUp(ref.read(_authRepositoryProvider)));
final _signOutProvider = Provider((ref) => SignOut(ref.read(_authRepositoryProvider)));

/// Estado de autenticación: loading y usuario actual.
class AuthState {
  final bool isLoading;
  final User? user;
  const AuthState({this.isLoading = false, this.user});
  AuthState copyWith({bool? isLoading, User? user}) =>
      AuthState(isLoading: isLoading ?? this.isLoading, user: user ?? this.user);
}

/// Notificador que expone signIn, signUp y signOut.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState(user: Supabase.instance.client.auth.currentUser);

  Future<String?> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(_signInProvider)(email: email, password: password);
      state = AuthState(user: Supabase.instance.client.auth.currentUser);
      return null;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false);
      return e.message;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return 'Error inesperado. Intenta de nuevo.';
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(_signUpProvider)(email: email, password: password, fullName: fullName);
      state = state.copyWith(isLoading: false);
      return null;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false);
      return e.message;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return 'Error inesperado. Intenta de nuevo.';
    }
  }

  Future<void> signOut() async {
    await ref.read(_signOutProvider)();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
