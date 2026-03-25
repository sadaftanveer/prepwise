import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import 'user_repository.dart';

class AuthRepository {
  AuthRepository({AuthService? authService, UserRepository? userRepository})
      : _authService = authService ?? AuthService(),
        _userRepository = userRepository ?? UserRepository();

  final AuthService _authService;
  final UserRepository _userRepository;

  Stream<User?> authStateChanges() => _authService.authStateChanges();

  String? currentUserId() => _authService.currentUserId();

  User? currentUser() => _authService.currentUser();

  Future<User?> login({required String email, required String password}) async {
    final User? user = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (user != null) {
      await _userRepository.upsertUser(user, provider: 'password');
    }
    return user;
  }

  Future<User?> signup({required String email, required String password}) async {
    final User? user = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (user != null) {
      await _userRepository.upsertUser(user, provider: 'password');
    }
    return user;
  }

  Future<User?> signInWithGoogle() async {
    final User? user = await _authService.signInWithGoogle();
    if (user != null) {
      await _userRepository.upsertUser(user, provider: 'google');
    }
    return user;
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() {
    return _authService.signOut();
  }

  Future<void> deleteAccount() => _authService.deleteAccount();
}
