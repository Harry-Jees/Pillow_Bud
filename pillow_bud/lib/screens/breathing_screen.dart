import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  static const List<_BreathingStep> _sequence = [
    _BreathingStep(
      label: 'Inhale',
      durationSeconds: 4,
      cue: 'Let the breath expand gently.',
      scale: 1.18,
    ),
    _BreathingStep(
      label: 'Hold',
      durationSeconds: 4,
      cue: 'Keep your shoulders soft.',
      scale: 1.18,
    ),
    _BreathingStep(
      label: 'Exhale',
      durationSeconds: 6,
      cue: 'Release a little more slowly.',
      scale: 0.86,
    ),
    _BreathingStep(
      label: 'Rest',
      durationSeconds: 2,
      cue: 'Notice the quiet before the next round.',
      scale: 0.96,
    ),
  ];

  Timer? _timer;
  int _stepIndex = 0;
  int _secondsLeft = _sequence.first.durationSeconds;
  int _roundsCompleted = 0;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _BreathingStep get _currentStep => _sequence[_stepIndex];

  double get _progress {
    final duration = _currentStep.durationSeconds;
    if (duration == 0) return 0;
    return 1 - (_secondsLeft / duration);
  }

  void _tick() {
    if (!_running) return;
    if (!mounted) return;

    if (_secondsLeft > 1) {
      setState(() => _secondsLeft--);
      return;
    }

    setState(() {
      _stepIndex = (_stepIndex + 1) % _sequence.length;
      _secondsLeft = _sequence[_stepIndex].durationSeconds;
      if (_stepIndex == 0) {
        _roundsCompleted++;
      }
    });
  }

  void _toggle() {
    setState(() => _running = !_running);
  }

  void _reset() {
    setState(() {
      _stepIndex = 0;
      _secondsLeft = _sequence.first.durationSeconds;
      _roundsCompleted = 0;
      _running = true;
    });
  }

  void _skipStep() {
    setState(() {
      _stepIndex = (_stepIndex + 1) % _sequence.length;
      _secondsLeft = _sequence[_stepIndex].durationSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Breathing'),
        actions: [
          TextButton(onPressed: _reset, child: const Text('Reset')),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              _statusCard(),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AnimatedScale(
                    scale: _currentStep.scale,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.07),
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.primary.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.55),
                                AppColors.primary.withValues(alpha: 0.16),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.22),
                                blurRadius: 36,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.air,
                              size: 58,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                _currentStep.label,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep.cue,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_secondsLeft seconds',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _toggle,
                      icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                      label: Text(_running ? 'Pause' : 'Resume'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _skipStep,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _chip('Rounds', '$_roundsCompleted'),
                  _chip('Phase', _currentStep.label),
                  _chip('Pattern', '4-4-6-2'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breathing guide',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Follow the circle and let the exhale settle your pace.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _BreathingStep {
  const _BreathingStep({
    required this.label,
    required this.durationSeconds,
    required this.cue,
    required this.scale,
  });

  final String label;
  final int durationSeconds;
  final String cue;
  final double scale;
}
