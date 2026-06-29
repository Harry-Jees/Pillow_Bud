import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  static const sessions = [
    _MeditationSession(
      title: 'Grounding',
      subtitle: 'Notice the room around you and let your attention land gently.',
      durationSeconds: 180,
      icon: Icons.landscape,
    ),
    _MeditationSession(
      title: 'Release',
      subtitle: 'Soften your shoulders and let each exhale take a little weight off.',
      durationSeconds: 300,
      icon: Icons.nights_stay,
    ),
    _MeditationSession(
      title: 'Quiet focus',
      subtitle: 'Keep your attention with the breath without forcing anything.',
      durationSeconds: 420,
      icon: Icons.center_focus_strong,
    ),
  ];

  Timer? _timer;
  int _selectedIndex = 0;
  late int _totalSeconds;
  late int _remainingSeconds;
  bool _running = false;
  bool _finishedShown = false;

  _MeditationSession get _session => sessions[_selectedIndex];

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  @override
  void initState() {
    super.initState();
    _loadSession(0, autoStart: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadSession(int index, {required bool autoStart}) {
    final session = sessions[index];
    setState(() {
      _selectedIndex = index;
      _totalSeconds = session.durationSeconds;
      _remainingSeconds = session.durationSeconds;
      _running = autoStart;
      _finishedShown = false;
    });
  }

  void _tick() {
    if (!_running || !mounted) return;

    if (_remainingSeconds <= 1) {
      setState(() {
        _remainingSeconds = 0;
        _running = false;
      });
      _showFinishedDialog();
      return;
    }

    setState(() => _remainingSeconds--);
  }

  Future<void> _showFinishedDialog() async {
    if (_finishedShown || !mounted) return;
    _finishedShown = true;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session complete'),
        content: const Text('Nice work. Take one slow breath before you move on.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadSession(_selectedIndex, autoStart: false);
            },
            child: const Text('Repeat'),
          ),
        ],
      ),
    );
  }

  void _toggle() {
    setState(() => _running = !_running);
  }

  void _reset() {
    _loadSession(_selectedIndex, autoStart: false);
  }

  void _extend() {
    setState(() {
      _remainingSeconds += 60;
      _totalSeconds += 60;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Meditation'),
        actions: [
          TextButton(onPressed: _reset, child: const Text('Reset')),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_session.icon, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        _session.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _session.subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.72), height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                      FilledButton(
                        onPressed: _toggle,
                        child: Text(_running ? 'Pause' : 'Start'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...List.generate(sessions.length, (index) {
              final session = sessions[index];
              final isSelected = index == _selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  tileColor: isSelected
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.04),
                  leading: Icon(session.icon, color: isSelected ? AppColors.primary : Colors.white54),
                  title: Text(session.title),
                  subtitle: Text(session.subtitle),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.chevron_right,
                    color: isSelected ? AppColors.primary : Colors.white54,
                  ),
                  onTap: () => _loadSession(index, autoStart: false),
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _extend,
                    icon: const Icon(Icons.add),
                    label: const Text('Add 1 min'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _running ? _toggle : null,
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Pause'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Tip: let your jaw unclench and keep the breath easy. No need to force stillness.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.58), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationSession {
  const _MeditationSession({
    required this.title,
    required this.subtitle,
    required this.durationSeconds,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final int durationSeconds;
  final IconData icon;
}
