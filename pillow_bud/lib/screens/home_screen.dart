import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/providers/theme_provider.dart';
import 'package:pillow_bud/services/database/database_service.dart';
import 'package:pillow_bud/theme/app_colors.dart';
import 'package:pillow_bud/widgets/calm_moment_sheet.dart';

import 'chat_screen.dart';
import 'journal_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  static const List<Map<String, String>> _moods = [
    {'emoji': '😤', 'label': 'Stressed'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😟', 'label': 'Anxious'},
  ];

  void _onMoodSelected(String emoji) async {
    ref.read(currentMoodProvider.notifier).state = emoji;
    try {
      await DatabaseService.logMood(emoji);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeColors = ref.watch(currentThemeProvider);
    final primary = themeColors['primary'] ?? AppColors.primary;

    final screens = <Widget>[
      _buildHomeContent(primary, isDarkMode),
      const ChatScreen(),
      const JournalScreen(),
      const InsightsScreen(),
      const ProfileScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 640;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _tabIndex,
                  onDestinationSelected: (i) => setState(() => _tabIndex = i),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primary.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Text('🛏️', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chat_bubble_outline),
                      selectedIcon: Icon(Icons.chat_bubble),
                      label: Text('Bud'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.edit_note_outlined),
                      selectedIcon: Icon(Icons.edit_note),
                      label: Text('Journal'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.show_chart_outlined),
                      selectedIcon: Icon(Icons.show_chart),
                      label: Text('Insights'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Me'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: _buildScreenTransition(screens[_tabIndex]),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          backgroundColor:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                // Keep scrollable content clear of the floating glass dock.
                padding: const EdgeInsets.only(bottom: 106),
                child: _buildScreenTransition(screens[_tabIndex]),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 8,
                child: _buildLiquidNavigation(primary, isDarkMode),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiquidNavigation(Color primary, bool isDarkMode) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final foreground =
        isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final muted =
        isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    const destinations = <({String label, IconData icon, IconData selectedIcon})>[
      (label: 'Home', icon: CupertinoIcons.house, selectedIcon: CupertinoIcons.house_fill),
      (label: 'Bud', icon: CupertinoIcons.chat_bubble, selectedIcon: CupertinoIcons.chat_bubble_fill),
      (label: 'Journal', icon: CupertinoIcons.book, selectedIcon: CupertinoIcons.book_fill),
      (label: 'Insights', icon: CupertinoIcons.chart_bar, selectedIcon: CupertinoIcons.chart_bar_fill),
      (label: 'Me', icon: CupertinoIcons.person_crop_circle, selectedIcon: CupertinoIcons.person_crop_circle_fill),
    ];

    return Semantics(
      container: true,
      label: 'Main navigation',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            decoration: BoxDecoration(
              color: (isDarkMode ? const Color(0xFF272333) : Colors.white)
                  .withValues(alpha: isDarkMode ? 0.76 : 0.72),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: (isDarkMode ? Colors.white : Colors.white)
                    .withValues(alpha: isDarkMode ? 0.16 : 0.78),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.22 : 0.10),
                  blurRadius: 32,
                  spreadRadius: -8,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: primary.withValues(alpha: isDarkMode ? 0.09 : 0.07),
                  blurRadius: 22,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Row(
              children: List.generate(destinations.length, (index) {
                final destination = destinations[index];
                final selected = _tabIndex == index;
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: destination.label,
                    child: Tooltip(
                      message: destination.label,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _tabIndex = index),
                          customBorder: const StadiumBorder(),
                          child: AnimatedContainer(
                            duration: reduceMotion
                                ? Duration.zero
                                : const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primary.withValues(alpha: isDarkMode ? 0.24 : 0.13)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(23),
                              border: selected
                                  ? Border.all(
                                      color: primary.withValues(alpha: 0.20),
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: selected ? 1.04 : 1,
                                  duration: reduceMotion
                                      ? Duration.zero
                                      : const Duration(milliseconds: 220),
                                  curve: Curves.easeOutBack,
                                  child: Icon(
                                    selected
                                        ? destination.selectedIcon
                                        : destination.icon,
                                    size: 22,
                                    color: selected ? primary : muted,
                                  ),
                                ),
                                AnimatedSize(
                                  duration: reduceMotion
                                      ? Duration.zero
                                      : const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  child: selected
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Text(
                                            destination.label,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 9,
                                              height: 1,
                                              fontWeight: FontWeight.w700,
                                              color: foreground,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(height: 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _showCalmMoment() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => const CalmMomentSheet(),
    );
  }

  Widget _buildScreenTransition(Widget screen) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AnimatedSwitcher(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 280),
      reverseDuration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = reduceMotion ? Offset.zero : const Offset(0.025, 0);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: offset, end: Offset.zero)
                .animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(_tabIndex),
        child: screen,
      ),
    );
  }

  Widget _buildHomeContent(Color primary, bool isDarkMode) {
    final userName = ref.watch(userNameProvider);
    final currentMood = ref.watch(currentMoodProvider);
    final displayName = userName.isNotEmpty ? userName : 'Friend';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // 1. Top Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, $displayName',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? const Color(0xFFECECF1)
                          : const Color(0xFF1A1225),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Welcome back to your safe space',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Encrypted',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Material 3 Mood Picker Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0x18FFFFFF)
                    : const Color(0x12000000),
              ),
              boxShadow: isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOW ARE YOU FEELING RIGHT NOW?',
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _moods.map((m) {
                    final isSelected = currentMood == m['emoji'];
                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: isSelected,
                        label: '${m['label']} mood',
                        child: GestureDetector(
                        onTap: () => _onMoodSelected(m['emoji']!),
                        child: AnimatedContainer(
                          duration: MediaQuery.maybeOf(context)?.disableAnimations == true
                              ? Duration.zero
                              : const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withValues(alpha: 0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                m['emoji']!,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                m['label']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? primary
                                      : (isDarkMode
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Bud Preview Card
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
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🌸', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bud is listening',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? const Color(0xFFECECF1)
                              : const Color(0xFF1A1225),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"I\'m here whenever you need to reflect. Completely private, never judged."',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Talk to Bud CTA
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _tabIndex = 1),
              icon: const Icon(Icons.chat_bubble_rounded, size: 20),
              label: const Text(
                'TALK TO BUD',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 5. Calm Studio entry point
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showCalmMoment,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.spa_rounded, color: primary, size: 23),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need a moment?',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Try guided breathing or a grounding exercise',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              height: 1.35,
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 6. Daily Prompt Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0x18FFFFFF)
                    : const Color(0x12000000),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded,
                        size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      'DAILY REFLECTION',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDarkMode
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'What is one small thing that brought peace or relief to your day?',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode
                        ? const Color(0xFFECECF1)
                        : const Color(0xFF1A1225),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _tabIndex = 2),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: Text(
                      'Write in Journal →',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
