import 'package:flutter/material.dart';

class LeaderboardWidget extends StatelessWidget {
  final int currentUserScore;
  final List<Map<String, dynamic>> participantsData; // Example: [{'name': 'You', 'score': 100}, {'name': 'Alex', 'score': 120}]

  const LeaderboardWidget({
    super.key,
    required this.currentUserScore,
    required this.participantsData,
  });

  @override
  Widget build(BuildContext context) {
    // Adapt the participantsData to match the structure used in QuizPlayScreen's dummy data
    // For example, if participantsData is List<Map<String, dynamic>> where each map is {'name': String, 'score': int}
    // And we need to derive a list of names and a map of scores for the existing UI logic.

    List<String> participantsNames = participantsData.map((p) => p['name'] as String).toList();
    Map<String, int> scores = {
      for (var p in participantsData) p['name'] as String: p['score'] as int
    };
    // Ensure 'You' is in the participantsNames if not already, and use currentUserScore for 'You'
    if (!participantsNames.contains('You')) {
      participantsNames.insert(0, 'You'); // Or some other logic to place 'You'
    }
    scores['You'] = currentUserScore;


    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leaderboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Use the length of actual participantsData or a combined list
              itemCount: participantsNames.length, 
              itemBuilder: (context, index) {
                final participantName = participantsNames[index];
                final score = scores[participantName] ?? 0;

                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: participantName == 'You'
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2)
                        : Theme.of(context).colorScheme.surface,
                    border: participantName == 'You'
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8), // Added for better aesthetics
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        participantName,
                        style: TextStyle(
                          fontWeight: participantName == 'You'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // Handle long names
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$score pts',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
