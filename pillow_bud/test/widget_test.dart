import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/screens/chat_screen.dart';
import 'package:pillow_bud/screens/home_screen.dart';
import 'package:pillow_bud/screens/journal_screen.dart';
import 'package:pillow_bud/widgets/indicators/typing_indicator.dart';

void main() {
  group('Pillow Bud Widget Tests', () {
    testWidgets('HomeScreen renders greeting and mood picker', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.textContaining('Hey,'), findsOneWidget);
      expect(find.text('TALK TO BUD'), findsOneWidget);
      expect(find.text('HOW ARE YOU FEELING RIGHT NOW?'), findsOneWidget);
    });

    testWidgets('ChatScreen renders header and input bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ChatScreen(),
          ),
        ),
      );

      expect(find.text('Bud'), findsOneWidget);
      expect(find.text('Share your thoughts with Bud...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('JournalScreen renders empty state when no entries', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: JournalScreen(),
          ),
        ),
      );

      expect(find.text('My Journal'), findsOneWidget);
      expect(find.text('Your Private Journal'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('TypingIndicator animates smoothly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingIndicator(),
          ),
        ),
      );

      expect(find.byType(TypingIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TypingIndicator), findsOneWidget);
    });
  });
}
