import 'package:first_app/widgets/app_features.dart';
import 'package:first_app/widgets/user_reviews.dart';
import 'package:first_app/widgets/voting_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [VotingCard(), VotingCard(), FeatureSection(), UserReviews()],
    );
  }
}
