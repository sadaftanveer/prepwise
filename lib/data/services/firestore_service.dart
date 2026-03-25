import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String name) {
    return _firestore.collection(name);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) {
    return _collection(collection).doc(documentId).get();
  }

  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) {
    return _collection(collection).doc(documentId).set(data, SetOptions(merge: merge));
  }

  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) {
    return _collection(collection).doc(documentId).delete();
  }
}
