import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../data/services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    UserRepository? userRepository,
    StorageService? storageService,
  })  : _userRepository = userRepository ?? UserRepository(),
        _storageService = storageService ?? StorageService() {
    load();
  }

  final UserRepository _userRepository;
  final StorageService _storageService;

  bool _isLoading = false;
  String? _error;

  String displayName = '';
  String email = '';
  String role = 'Aspiring Flutter Developer';
  String? photoUrl;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    final User? user = FirebaseAuth.instance.currentUser;
    displayName = user?.displayName ?? 'PrepWise User';
    email = user?.email ?? '';
    photoUrl = user?.photoURL;
    notifyListeners();
  }

  Future<void> updateProfileImage(File file) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = 'No authenticated user';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final String url =
          await _storageService.uploadProfileImage(userId: user.uid, file: file);
      await user.updatePhotoURL(url);
      await _userRepository.updatePhotoUrl(userId: user.uid, photoUrl: url);
      photoUrl = url;
    } catch (_) {
      _error = 'Failed to update profile image';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
