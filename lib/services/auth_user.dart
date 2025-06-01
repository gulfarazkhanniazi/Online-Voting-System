import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  bool _isEmailValid(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  bool _isCnicValid(String cnic) {
    final regex = RegExp(r'^\d{12,}$');
    return regex.hasMatch(cnic);
  }

  Future<String> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    required String cnic,
  }) async {
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        role.isEmpty ||
        cnic.isEmpty) {
      return 'All fields are required.';
    }
    if (name.length < 3) return 'Name must be at least 3 characters.';
    if (!_isEmailValid(email)) return 'Invalid email format.';
    if (password.length < 5) return 'Password must be at least 5 characters.';
    if (!_isCnicValid(cnic)) {
      return 'CNIC must be at least 12 digits and numeric.';
    }

    // Check if CNIC already exists in Firestore
    final existingCnic =
        await _firestore
            .collection('users')
            .where('cnic', isEqualTo: cnic)
            .get();
    if (existingCnic.docs.isNotEmpty) return 'CNIC already exists.';

    try {
      // Create user in Firebase Auth
      final fb_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final fb_auth.User? fbUser = userCredential.user;
      if (fbUser == null) return 'Failed to create user.';

      // Create user model with Firebase UID
      final user = User(
        id: fbUser.uid,
        name: name,
        email: email,
        role: role,
        cnic: cnic,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(fbUser.uid).set(user.toJson());

      return 'Signup successful';
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      if (e.code == 'email-already-in-use') {
        return 'Email already exists.';
      } else if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else {
        return e.message ?? 'An error occurred during signup.';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  Future<User?> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty.');
    }

    try {
      // Sign in with Firebase Auth
      final fb_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final fb_auth.User? fbUser = userCredential.user;
      if (fbUser == null) throw Exception('User not found after login.');

      // Fetch user data from Firestore using UID
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (!doc.exists) throw Exception('User data not found.');

      final data = doc.data()!;
      final user = User.fromJson(data);

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('User not found.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      } else {
        throw Exception(e.message ?? 'Failed to login.');
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Return the current logged-in Firebase user
  fb_auth.User? get currentUser => _auth.currentUser;

  /// Listen to auth state changes (login/logout)
  Stream<fb_auth.User?> authStateChanges() => _auth.authStateChanges();
}
