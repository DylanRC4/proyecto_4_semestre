import 'package:flutter_test/flutter_test.dart';
import 'package:flash_app/features/auth/domain/usecases/sign_in.dart';
import 'package:flash_app/features/auth/domain/usecases/sign_up.dart';
import 'package:flash_app/features/auth/domain/usecases/sign_out.dart';
import 'package:flash_app/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  bool _isAuthenticated = false;
  String? _currentEmail;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password required');
    }
    if (password.length < 6) {
      throw Exception('Password too short');
    }
    _isAuthenticated = true;
    _currentEmail = email;
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      throw Exception('All fields required');
    }
    _isAuthenticated = false;
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentEmail = null;
  }

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  String? get currentUserEmail => _currentEmail;
}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('SignIn UseCase', () {
    test('should authenticate user with valid credentials', () async {
      final signIn = SignIn(repository);
      await signIn(email: 'test@test.com', password: '123456');
      expect(repository.isAuthenticated, true);
      expect(repository.currentUserEmail, 'test@test.com');
    });

    test('should throw on empty email', () async {
      final signIn = SignIn(repository);
      expect(
        () => signIn(email: '', password: '123456'),
        throwsException,
      );
    });

    test('should throw on short password', () async {
      final signIn = SignIn(repository);
      expect(
        () => signIn(email: 'test@test.com', password: '123'),
        throwsException,
      );
    });
  });

  group('SignUp UseCase', () {
    test('should register user with valid data', () async {
      final signUp = SignUp(repository);
      await signUp(
        email: 'new@test.com',
        password: '123456',
        fullName: 'Test User',
      );
      expect(repository.isAuthenticated, false);
    });

    test('should throw on empty fields', () async {
      final signUp = SignUp(repository);
      expect(
        () => signUp(email: '', password: '123456', fullName: 'Test'),
        throwsException,
      );
    });
  });

  group('SignOut UseCase', () {
    test('should clear authentication state', () async {
      final signIn = SignIn(repository);
      final signOut = SignOut(repository);

      await signIn(email: 'test@test.com', password: '123456');
      expect(repository.isAuthenticated, true);

      await signOut();
      expect(repository.isAuthenticated, false);
      expect(repository.currentUserEmail, null);
    });
  });
}