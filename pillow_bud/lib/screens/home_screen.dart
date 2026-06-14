import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/theme/app_colors.dart';

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
      body: screens[_tabIndex],
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
}

