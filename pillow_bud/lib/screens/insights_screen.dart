import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/services/date_utils.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalEntriesProvider);
    final streak = DateUtils.calculateStreak(
      entries.map((entry) => entry.dateCreated).toList(),
    );

    final recentDays = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final dayLabel = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      final dayEntries = entries.where((entry) {
        final created = entry.dateCreated;
        return created.year == date.year &&
            created.month == date.month &&
            created.day == date.day;
      }).toList();
      final score = dayEntries.isEmpty ? 10 : (dayEntries.length * 20).clamp(10, 100).toDouble();
      final emoji = dayEntries.isNotEmpty ? dayEntries.last.mood : '—';
      return {'label': dayLabel, 'score': score, 'emoji': emoji};
    });

    final moodCounts = <String, int>{};
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Insights',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak days',
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Current check-in streak',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mood this week',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: recentDays.map((dayData) {
                  final score = dayData['score'] as double;
                  final emoji = dayData['emoji'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            dayData['label'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              height: 8,
                              color: Colors.white.withValues(alpha: 0.1),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: score,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Emotional patterns',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 12),
            ...moodCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    Text(
                      '${entry.value} entries',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
