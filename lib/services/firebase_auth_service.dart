import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        code: 'user-not-created',
        message: 'User was not created successfully.',
      );
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    return _auth.signOut();
  }

  // Get User Details
  Future<Map<String, dynamic>?> getUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) return doc.data();

    return null;
  }

  // Get Current user
  User? get currentUser {
    return _auth.currentUser;
  }
}
