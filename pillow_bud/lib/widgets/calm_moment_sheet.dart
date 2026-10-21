import 'package:flutter/material.dart';
import 'package:pillow_bud/theme/app_colors.dart';

/// A small, offline-friendly pause with guided breathing and grounding prompts.
class CalmMomentSheet extends StatefulWidget {
  const CalmMomentSheet({super.key});

  @override
  State<CalmMomentSheet> createState() => _CalmMomentSheetState();
}

class _CalmMomentSheetState extends State<CalmMomentSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;
  bool _isBreathing = false;
  bool _isGrounding = false;
  String _phase = 'Ready when you are';

  static const List<Map<String, String>> _groundingSteps = [
    {'count': '5', 'label': 'things you can see', 'icon': 'visibility_outlined'},
    {'count': '4', 'label': 'things you can feel', 'icon': 'touch_app_outlined'},
    {'count': '3', 'label': 'things you can hear', 'icon': 'hearing_outlined'},
    {'count': '2', 'label': 'things you can smell', 'icon': 'air_outlined'},
    {'count': '1', 'label': 'thing you can taste', 'icon': 'restaurant_outlined'},
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      value: 0.5,
    )..addStatusListener(_onBreathStatusChanged);
  }

  void _onBreathStatusChanged(AnimationStatus status) {
    if (!mounted || !_isBreathing) return;
    setState(() {
      _phase = status == AnimationStatus.reverse ? 'Breathe out' : 'Breathe in';
    });
  }

  void _toggleBreathing() {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    setState(() {
      _isBreathing = !_isBreathing;
      _isGrounding = false;
      _phase = _isBreathing
          ? (reduceMotion ? 'Breathe at your own pace' : 'Breathe in')
          : 'Ready when you are';
    });

    if (!_isBreathing) {
      _breathController.stop();
      _breathController.value = 0.5;
    } else if (!reduceMotion) {
      _breathController.forward(from: 0).then((_) {
        if (mounted && _isBreathing) {
          _breathController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _breathController
      ..removeStatusListener(_onBreathStatusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.spa_rounded, color: primary, size: 25),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A little pause',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'No pressure. Just come back to this moment.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close calm studio',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBackground : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, child) {
                      final scale = reduceMotion || !_isBreathing
                          ? 1.0
                          : 0.78 + (_breathController.value * 0.32);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 142,
                          height: 142,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withValues(alpha: 0.12),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.55),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 94,
                              height: 94,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary.withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                Icons.self_improvement_rounded,
                                color: primary,
                                size: 42,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    child: Text(
                      _phase,
                      key: ValueKey<String>(_phase),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Follow the circle if it feels comfortable. There is no wrong way to do this.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _toggleBreathing,
                      icon: Icon(
                        _isBreathing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      ),
                      label: Text(_isBreathing ? 'Pause breathing' : 'Start breathing'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _isGrounding = !_isGrounding;
                  if (_isGrounding && _isBreathing) {
                    _isBreathing = false;
                    _breathController.stop();
                    _breathController.value = 0.5;
                    _phase = 'Ready when you are';
                  }
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_vintage_rounded, color: primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '5–4–3–2–1 grounding',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          _isGrounding
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Gently notice the world around you, one sense at a time.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_isGrounding) ...[
                      const SizedBox(height: 14),
                      ..._groundingSteps.map(
                        (step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.13),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Text(
                                  step['count']!,
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step['label']!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'Skip any step that does not feel right. Take your time.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
