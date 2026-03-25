import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/question_model.dart';

class QuestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<QuestionModel>> fetchQuestions() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const <QuestionModel>[];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('questions')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return QuestionModel.fromMap(data);
        })
        .toList();
  }

  Future<void> addQuestion(QuestionModel question) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No authenticated user');
    }
    final Map<String, dynamic> data = question.toMap();
    data['userId'] = uid;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('questions').doc(question.id).set(data);
  }

  Future<void> updateQuestion(QuestionModel question) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No authenticated user');
    }
    final Map<String, dynamic> data = question.toMap();
    data['userId'] = uid;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('questions').doc(question.id).set(data);
  }

  Future<void> deleteQuestion(String questionId) async {
    await _firestore.collection('questions').doc(questionId).delete();
  }
}
