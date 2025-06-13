import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/election_model.dart';

class ElectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addElection(Election election) async {
    try {
      await _firestore
          .collection('elections')
          .doc(election.id)
          .set(election.toJson());
      return "Election added successfully!";
    } catch (e) {
      return "Failed to add election: $e";
    }
  }

  Future<List<Election>> getAllElections() async {
    final snapshot = await _firestore.collection('elections').get();
    return snapshot.docs.map((doc) => Election.fromJson(doc.data())).toList();
  }

  Future<void> deleteElection(String electionId) async {
    await _firestore.collection('elections').doc(electionId).delete();
  }

  Future<String> voteOnce({
    required String cnic,
    required String electionId,
    required String selectedCandidate,
  }) async {
    final electionRef = _firestore.collection('elections').doc(electionId);

    try {
      // 1. Find user by CNIC
      final userQuery =
          await _firestore
              .collection('users')
              .where('cnic', isEqualTo: cnic)
              .limit(1)
              .get();

      if (userQuery.docs.isEmpty) return "User not found.";

      final userDoc = userQuery.docs.first;
      final userRef = userDoc.reference;

      // 2. Check if election exists
      final electionDoc = await electionRef.get();
      if (!electionDoc.exists) return "Election not found.";

      final userData = userDoc.data();
      final votedElections = List<String>.from(
        userData['votedElections'] ?? [],
      );

      if (votedElections.contains(electionId)) {
        return "You have already voted in this election.";
      }

      // 3. Update candidate vote count in `candidates` map
      final electionData = electionDoc.data();
      final candidatesMap = Map<String, dynamic>.from(
        electionData?['candidates'] ?? {},
      );

      candidatesMap[selectedCandidate] =
          (candidatesMap[selectedCandidate] ?? 0) + 1;

      // 4. Update Firestore
      await Future.wait([
        electionRef.update({'candidates': candidatesMap}),
        userRef.update({
          'votedElections': FieldValue.arrayUnion([electionId]),
        }),
      ]);

      return "Vote submitted successfully.";
    } catch (e) {
      return "Error: $e";
    }
  }
}
