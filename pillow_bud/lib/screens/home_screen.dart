import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/theme/app_colors.dart';

import 'chat_screen.dart';
import 'journal_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'breathing_screen.dart';
import 'meditation_screen.dart';
import 'pacman_game_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(currentMoodProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    final screens = <Widget>[
      const ChatScreen(),
      const JournalScreen(),
      const InsightsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
      body: Column(
        children: [
          _buildToolsStrip(context),
          Expanded(child: screens[_tabIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMutedDark,
        backgroundColor: AppColors.darkBackground,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit_note), label: 'Journal'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: 'Insights'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      appBar: AppBar(
        title: Text('Pillow Bud', style: TextStyle(color: AppColors.textPrimaryDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                mood,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _toolCard(
              icon: Icons.air,
              title: 'Breathing',
              subtitle: 'Reset your pace',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BreathingScreen()),
              ),
            ),
            const SizedBox(width: 12),
            _toolCard(
              icon: Icons.self_improvement,
              title: 'Meditation',
              subtitle: 'Quiet focus',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MeditationScreen()),
              ),
            ),
            const SizedBox(width: 12),
            _toolCard(
              icon: Icons.videogame_asset,
              title: 'Mini Pac Bud',
              subtitle: 'Quick game',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PacmanGameScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

