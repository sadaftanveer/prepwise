import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _userId = _authRepository.currentUserId();
    _authSub = _authRepository.authStateChanges().listen((User? user) {
      _userId = user?.uid;
      notifyListeners();
    });
  }

  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSub;

  bool _isLoading = false;
  String? _userId;
  String? _error;
  String? _statusMessage;

  bool get isLoading => _isLoading;
  String? get userId => _userId;
  String? get error => _error;
  String? get statusMessage => _statusMessage;
  bool get isAuthenticated => _userId != null;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    _statusMessage = null;
    notifyListeners();

    try {
      final User? user =
          await _authRepository.login(email: email, password: password);
      _userId = user?.uid;
      return user != null;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      return false;
    } catch (_) {
      _error = 'Login failed. Try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    _statusMessage = null;
    notifyListeners();

    try {
      final User? user =
          await _authRepository.signup(email: email, password: password);
      _userId = user?.uid;
      if (user != null) {
        _statusMessage = 'Account created successfully.';
      }
      return user != null;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      return false;
    } catch (_) {
      _error = 'Signup failed. Try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    _statusMessage = null;
    notifyListeners();

    try {
      final User? user = await _authRepository.signInWithGoogle();
      _userId = user?.uid;
      if (user == null) {
        _error = 'Google sign-in cancelled.';
        return false;
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      return false;
    } catch (_) {
      _error = 'Google sign-in failed. Try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    _isLoading = true;
    _error = null;
    _statusMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      _statusMessage = 'Password reset email sent. Check your inbox.';
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      return false;
    } catch (_) {
      _error = 'Failed to send reset email. Try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _userId = null;
      _error = null;
      _statusMessage = null;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    if (_userId == null) {
      _error = 'No authenticated user';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    _statusMessage = null;
    notifyListeners();

    try {
      await _authRepository.deleteAccount();
      _userId = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e);
      return false;
    } catch (_) {
      _error = 'Failed to delete account. Try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearStatus() {
    _statusMessage = null;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    _userId = _authRepository.currentUserId();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Invalid credentials.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'account-exists-with-different-credential':
        return 'Account exists with a different sign-in method.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password auth is not enabled.';
      case 'requires-recent-login':
        return 'Please re-login to delete your account.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'user-token-expired':
        return 'Your session expired. Please sign in again.';
      default:
        return 'Authentication failed.';
    }
  }
}
