import 'package:flutter/material.dart';

class FeatureSection extends StatelessWidget {
  const FeatureSection({super.key});

  final List<Map<String, dynamic>> features = const [
    {
      "icon": Icons.lock_outline,
      "title": "Secure Voting",
      "desc": "Votes are encrypted & tamper-proof.",
    },
    {
      "icon": Icons.leaderboard,
      "title": "Live Results",
      "desc": "See real-time results as votes come in.",
    },
    {
      "icon": Icons.phone_android,
      "title": "Mobile Friendly",
      "desc": "Vote easily from any mobile device.",
    },
    {
      "icon": Icons.how_to_vote,
      "title": "One Tap Voting",
      "desc": "Clean UI with single-tap voting access.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Center(
            child: Text(
              "App Features",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          padding: const EdgeInsets.all(8),
          children:
              features.map((feature) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(feature["icon"], size: 30, color: Colors.blue),
                        const SizedBox(height: 10),
                        Text(
                          feature["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature["desc"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
