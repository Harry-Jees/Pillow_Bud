import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/date_utils.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalEntriesProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;

    final streak = DateUtils.calculateStreak(
      entries.map((entry) => entry.dateCreated).toList(),
    );

    final recentDays = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final dayLabel =
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      final dayEntries = entries.where((entry) {
        final created = entry.dateCreated;
        return created.year == date.year &&
            created.month == date.month &&
            created.day == date.day;
      }).toList();

      final score = dayEntries.isEmpty
          ? 0.08
          : (dayEntries.length * 0.35).clamp(0.2, 1.0);
      final emoji = dayEntries.isNotEmpty ? dayEntries.first.mood : '—';
      return {
        'label': dayLabel,
        'score': score,
        'emoji': emoji,
        'count': dayEntries.length
      };
    });

    final moodCounts = <String, int>{};
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Your Insights',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? const Color(0xFFECECF1)
                : const Color(0xFF1A1225),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. Streak Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: 0.16),
                    primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: primary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🔥', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak Day${streak == 1 ? '' : 's'} Streak',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Consistent check-ins deepen emotional self-awareness',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Weekly Mood Flow
            Text(
              'WEEKLY ACTIVITY & MOOD',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x12000000),
                ),
              ),
              child: Column(
                children: recentDays.map((dayData) {
                  final score = dayData['score'] as double;
                  final emoji = dayData['emoji'] as String;
                  final label = dayData['label'] as String;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 10,
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: score,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: score),
                                  duration: MediaQuery.maybeOf(context)?.disableAnimations == true
                                      ? Duration.zero
                                      : const Duration(milliseconds: 650),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, animatedScore, _) => FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: animatedScore,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 28,
                          child: Text(
                            emoji,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // 3. Emotional Breakdown
            Text(
              'EMOTIONAL PATTERNS',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: isDarkMode
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 12),
            if (moodCounts.isEmpty)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0x18FFFFFF)
                        : const Color(0x12000000),
                  ),
                ),
                child: Center(
                  child: Text(
                    'No journal logs yet. Write your first encrypted reflection to view patterns.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: isDarkMode
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0x18FFFFFF)
                        : const Color(0x12000000),
                  ),
                ),
                child: Column(
                  children: moodCounts.entries.map((entry) {
                    final percentage =
                        ((entry.value / entries.length) * 100).toStringAsFixed(0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(entry.key,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value} ${entry.value == 1 ? 'entry' : 'entries'}',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? const Color(0xFFECECF1)
                                      : const Color(0xFF1A1225),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$percentage%',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
