import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/candidate.dart';
import '../providers/provider.dart';
import '../services/candidate_service.dart';
import '../widgets/candidate_card.dart';
import './new_candidate.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  List<Candidate> _candidates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    final candidates = await CandidateService().getCandidates();
    setState(() {
      _candidates = candidates;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.role == 'admin';

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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCandidateScreen(),
                    ),
                  );

                  if (result == true) {
                    await _fetchCandidates(); // Refresh after adding
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Candidate"),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              )
              : null,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _candidates.isEmpty
              ? const Center(child: Text("No candidates found."))
              : Container(
                color: const Color(0xFFF5F5F5),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = _candidates[index];
                    return CandidateCard(
                      candidate: candidate,
                      isAdmin: isAdmin,
                      onEdit: () {
                        // Navigate to edit
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Delete Candidate"),
                                content: const Text(
                                  "Are you sure you want to delete this candidate?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await CandidateService().deleteCandidate(
                            candidate.id,
                          );
                          await _fetchCandidates(); // Refresh list
                        }
                      },
                    );
                  },
                ),
              ),
    );
  }
}
