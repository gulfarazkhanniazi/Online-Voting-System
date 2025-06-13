import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/election_model.dart';
import '../services/election_service.dart';
import '../widgets/voting_card.dart';
import '../widgets/user_reviews.dart';
import '../widgets/app_features.dart';
import '../providers/provider.dart';
import '../screens/add_election.dart'; // Create this screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Election> _elections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchElections();
  }

  Future<void> fetchElections() async {
    final elections = await ElectionService().getAllElections();
    elections.sort((a, b) {
      final now = DateTime.now();
      final aEnded = now.isAfter(a.endDate);
      final bEnded = now.isAfter(b.endDate);

      if (aEnded && !bEnded) return 1; // a comes after b
      if (!aEnded && bEnded) return -1; // a comes before b
      return a.startDate.compareTo(b.startDate); // optional: sort within group
    });

    setState(() {
      _elections = elections;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.role == 'admin';

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 8),
                  if (_elections.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "There are currently no elections available.\nPlease check back later.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: const Text(
                        "Available Elections",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ..._elections.map(
                    (election) => VotingCard(
                      key: ValueKey(election.id),
                      election: election,
                      onElectionDeleted: fetchElections,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "App Features",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const FeatureSection(),
                  const SizedBox(height: 20),
                  const Text(
                    "User Reviews",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const UserReviews(),
                ],
              ),
      floatingActionButton:
          isAdmin
              ? FloatingActionButton.extended(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddElectionScreen(),
                    ),
                  );
                  if (result == true) {
                    await fetchElections(); // Refresh after adding
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Election"),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              )
              : null,
    );
  }
}
