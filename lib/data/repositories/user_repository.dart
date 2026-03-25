import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';

class UserRepository {
  UserRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  Future<void> upsertUser(User user, {required String provider}) async {
    final String uid = user.uid;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestoreService.getDocument(collection: 'users', documentId: uid);

    final Map<String, dynamic> data = <String, dynamic>{
      'uid': uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'provider': provider,
      'lastLogin': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await _firestoreService.setDocument(
      collection: 'users',
      documentId: uid,
      data: data,
      merge: true,
    );
  }

  Future<void> updatePhotoUrl({
    required String userId,
    required String photoUrl,
  }) async {
    await _firestoreService.setDocument(
      collection: 'users',
      documentId: userId,
      data: <String, dynamic>{
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      merge: true,
    );
  }
}
