import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_iti_movie_app/utils/app_exception.dart";

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e), code: e.code);
    } catch (_) {
      throw const AppException('Sign-in failed. Please try again later.');
    }
  }

  // Sign up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw const AppException('User account was not created successfully.');
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e), code: e.code);
    } on FirebaseException catch (e) {
      throw AppException(
        'Account creation could not be completed. Please try again.',
        code: e.code,
      );
    } catch (_) {
      throw const AppException('Sign-up failed. Please try again later.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseException catch (e) {
      throw AppException('Sign-out failed. Please try again.', code: e.code);
    }
  }

  // Get User Details
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) return doc.data();
      return null;
    } on FirebaseException catch (e) {
      throw AppException('Unable to load user details.', code: e.code);
    }
  }

  // Get Current user
  User? get currentUser {
    return _auth.currentUser;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email address or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
