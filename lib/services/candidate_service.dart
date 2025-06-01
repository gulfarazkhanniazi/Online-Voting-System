import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/candidate.dart';

class CandidateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Check if a user is authenticated
  bool get _isUserLoggedIn => _auth.currentUser != null;

  /// Check if the current user is an admin
  Future<bool> _isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;

    final role = doc.data()?['role'];
    return role == 'admin';
  }

  /// Add a new candidate (only for admin users)
  Future<String> addCandidate(Candidate candidate) async {
    if (!_isUserLoggedIn) return 'User is not authenticated.';
    if (!await _isAdmin()) return 'Only admin can add candidates.';

    try {
      final docRef = _firestore.collection('candidates').doc(candidate.id);
      await docRef.set(candidate.toJson());
      return 'Candidate added successfully';
    } catch (e) {
      return 'Failed to add candidate: $e';
    }
  }

  /// Get all candidates (accessible to everyone)
  Future<List<Candidate>> getCandidates() async {
    try {
      final snapshot = await _firestore.collection('candidates').get();
      return snapshot.docs
          .map((doc) => Candidate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a candidate (only for admin users)
  Future<String> deleteCandidate(String id) async {
    if (!_isUserLoggedIn) return 'User is not authenticated.';
    if (!await _isAdmin()) return 'Only admin can delete candidates.';

    try {
      await _firestore.collection('candidates').doc(id).delete();
      return 'Candidate deleted successfully';
    } catch (e) {
      return 'Failed to delete candidate: $e';
    }
  }
}
