import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String? currentUserId() => _auth.currentUser?.uid;

  User? currentUser() => _auth.currentUser;

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final GoogleAuthProvider provider = GoogleAuthProvider()..addScope('email');
      final UserCredential userCredential = await _auth.signInWithPopup(provider);
      return userCredential.user;
    }

    final GoogleSignIn googleSignIn = _createGoogleSignIn();

    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      return null;
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _createGoogleSignIn().signOut();
    }
  }

  Future<void> deleteAccount() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    await user.delete();
    if (!kIsWeb) {
      await _createGoogleSignIn().disconnect();
    }
  }

  GoogleSignIn _createGoogleSignIn() {
    return GoogleSignIn(
      scopes: <String>['email'],
    );
  }
}
