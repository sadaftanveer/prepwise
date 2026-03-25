import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage({
    required String userId,
    required File file,
  }) async {
    final Reference ref =
        _storage.ref().child('user_uploads/$userId/profile.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<String> uploadAttachment({
    required String userId,
    required File file,
    required String filename,
  }) async {
    final String safeName = filename.replaceAll(' ', '_');
    final Reference ref = _storage
        .ref()
        .child('user_uploads/$userId/attachments/${DateTime.now().millisecondsSinceEpoch}-$safeName');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
