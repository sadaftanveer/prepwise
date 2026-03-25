import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/interview_resources.dart';
import '../models/saved_resource_model.dart';

class ResourcesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _cacheKey = 'saved_resources_cache_v1';

  Stream<List<SavedResource>> watchSaved() {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream<List<SavedResource>>.value(const <SavedResource>[]);
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('resources')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
                return SavedResource.fromDoc(doc);
              })
              .toList(),
        );
  }

  Future<void> saveResource({
    required ResourceLink link,
    required String category,
  }) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No authenticated user');
    }
    final String docId = _resourceId(link.url);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('resources')
        .doc(docId)
        .set(<String, dynamic>{
      'title': link.title,
      'url': link.url,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeResource({required String resourceId}) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No authenticated user');
    }
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('resources')
        .doc(resourceId)
        .delete();
  }

  String resourceIdFromUrl(String url) => _resourceId(url);

  Future<void> cacheSaved(List<SavedResource> resources) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encoded = resources
        .map((SavedResource r) => jsonEncode(r.toMap()))
        .toList();
    await prefs.setStringList(_cacheKey, encoded);
  }

  Future<List<SavedResource>> loadCachedSaved() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encoded = prefs.getStringList(_cacheKey) ?? <String>[];
    return encoded
        .map((String raw) =>
            SavedResource.fromMap(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  String _resourceId(String url) {
    final String encoded = base64UrlEncode(utf8.encode(url));
    return encoded.replaceAll('=', '');
  }
}
