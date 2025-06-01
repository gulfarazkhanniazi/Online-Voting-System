import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/candidate.dart';
import '../providers/provider.dart';
import '../widgets/candidate_card.dart';

class CandidatesScreen extends StatelessWidget {
  const CandidatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.role == 'admin';

    // Sample data (replace with Firestore fetch later)
    final candidates = [
      Candidate(
        id: '1',
        name: 'Ali Khan',
        symbol: 'Lion 🦁',
        party: 'PMLN',
        slogan: 'Vote for Progress',
      ),
      Candidate(
        id: '2',
        name: 'Sara Malik',
        symbol: 'Bat 🏏',
        party: 'PTI',
        slogan: 'Naya Pakistan',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Candidates'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      floatingActionButton:
          isAdmin
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Navigate to add candidate
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Candidate"),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              )
              : null,
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: candidates.length,
          itemBuilder: (context, index) {
            final candidate = candidates[index];
            return CandidateCard(
              candidate: candidate,
              isAdmin: isAdmin,
              onEdit: () {
                // Navigate to edit
              },
              onDelete: () {
                // Confirm delete
              },
            );
          },
        ),
      ),
    );
  }
}
