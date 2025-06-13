import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/election_model.dart';
import '../models/candidate.dart';
import '../providers/provider.dart';
import '../services/candidate_service.dart';
import '../services/election_service.dart';

class VotingCard extends StatefulWidget {
  final Election election;
  final VoidCallback onElectionDeleted;

  const VotingCard({
    super.key,
    required this.election,
    required this.onElectionDeleted,
  });

  @override
  State<VotingCard> createState() => _VotingCardState();
}

class _VotingCardState extends State<VotingCard> {
  String? _selectedCandidate;
  Map<String, Candidate> _candidateDetails = {};

  @override
  void initState() {
    super.initState();
    _loadCandidateDetails();
  }

  Future<void> _loadCandidateDetails() async {
    final service = CandidateService();
    final fetched = <String, Candidate>{};

    for (final id in widget.election.candidates.keys) {
      final candidate = await service.getCandidateById(id);
      if (candidate != null) {
        fetched[id] = candidate;
      }
    }

    setState(() {
      _candidateDetails = fetched;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isEnded = now.isAfter(widget.election.endDate);
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.role == 'admin';
    final isLoggedIn = userProvider.cnic.isNotEmpty;

    final sortedEntries =
        widget.election.candidates.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final totalVotes = sortedEntries.fold<int>(0, (sum, e) => sum + e.value);
    final highestVotes =
        sortedEntries.isNotEmpty ? sortedEntries.first.value : 0;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.election.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Ends on: ${DateFormat.yMMMMd().format(widget.election.endDate)}",
            ),
            const SizedBox(height: 20),

            ...sortedEntries.map((entry) {
              final candidateId = entry.key;
              final candidate = _candidateDetails[candidateId];
              final votes = entry.value;
              final isTop = isEnded && votes == highestVotes;
              final percent = totalVotes > 0 ? votes / totalVotes : 0.0;

              final label =
                  candidate != null
                      ? "${candidate.name} (${candidate.party})"
                      : "Candidate ID: $candidateId";

              return InkWell(
                onTap:
                    (!isEnded && isLoggedIn)
                        ? () {
                          setState(() {
                            _selectedCandidate = candidateId;
                          });
                        }
                        : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        isEnded
                            ? Icon(
                              isTop ? Icons.emoji_events : Icons.circle,
                              color: isTop ? Colors.green : Colors.grey,
                            )
                            : Radio<String>(
                              value: candidateId,
                              groupValue: _selectedCandidate,
                              onChanged:
                                  (!isLoggedIn)
                                      ? null
                                      : (value) {
                                        setState(() {
                                          _selectedCandidate = value;
                                        });
                                      },
                            ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "$label - $votes votes",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isTop ? Colors.green : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }),

            if (!isEnded && isLoggedIn)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed:
                      _selectedCandidate == null
                          ? null
                          : () async {
                            final result = await ElectionService().voteOnce(
                              cnic: userProvider.cnic,
                              electionId: widget.election.id,
                              selectedCandidate: _selectedCandidate!,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(result)));
                              widget.onElectionDeleted(); // Trigger reload
                            }
                          },
                  child: const Text("Vote"),
                ),
              ),

            if (!isEnded && !isLoggedIn)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Please log in to vote.",
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            if (isAdmin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text(
                    "Cancel Election",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text("Cancel Election"),
                            content: const Text(
                              "Are you sure you want to cancel this election?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      await ElectionService().deleteElection(
                        widget.election.id,
                      );
                      widget.onElectionDeleted(); // Trigger reload
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
