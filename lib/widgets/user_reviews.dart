import 'package:flutter/material.dart';

const List<Map<String, dynamic>> reviews = [
  {
    "name": "Ayesha R.",
    "comment": "Super smooth and secure voting! Love the real-time results.",
    "rating": 5,
  },
  {
    "name": "Rohit M.",
    "comment": "Very user-friendly UI and easy to vote. Great job!",
    "rating": 4,
  },
  {
    "name": "Zara K.",
    "comment": "Perfect app for our college elections. Highly recommend!",
    "rating": 5,
  },
];

class UserReviews extends StatelessWidget {
  const UserReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "What Users Say",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        ...reviews.map(
          (review) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        review["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review["rating"]
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(review["comment"], style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
