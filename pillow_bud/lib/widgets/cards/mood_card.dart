import 'package:flutter/material.dart';

class MoodCard extends StatelessWidget {
  const MoodCard({
    super.key,
    required this.mood,
    required this.description,
    required this.onTap,
  });

  final String mood;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mood, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }
}
