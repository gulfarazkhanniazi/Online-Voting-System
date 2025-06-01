import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VotingCard extends StatelessWidget {
  final String heading = "Class Representative Election";
  final DateTime endDate = DateTime(2025, 4, 5);
  final Map<String, int> candidates = {"Alice": 50, "Bob": 30, "Charlie": 20};

  VotingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool pollEnded = DateTime.now().isAfter(endDate);
    final int totalVotes = candidates.values.fold(0, (a, b) => a + b);
    final int highestVotes = candidates.values.reduce((a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Ends on: ${DateFormat.yMMMMd().format(endDate)}"),
            const SizedBox(height: 20),
            ...candidates.entries.map((entry) {
              double percent = totalVotes > 0 ? entry.value / totalVotes : 0.0;
              bool isWinner = pollEnded && entry.value == highestVotes;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      pollEnded
                          ? Icon(
                            isWinner
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isWinner ? Colors.green : Colors.grey,
                          )
                          : Radio(
                            value: entry.key,
                            groupValue: null,
                            onChanged: (_) {},
                          ),
                      Text(
                        "${entry.key} - ${entry.value} votes",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isWinner ? Colors.green : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
