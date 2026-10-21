import 'package:flutter/material.dart';
import 'package:pillow_bud/services/storage_service.dart';
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
  String _selectedSmallStep = '';
  List<String> _copingPlan = [];
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _balancedThoughtController = TextEditingController();

  static const List<String> _smallSteps = [
    'Drink a glass of water',
    'Take a minute of fresh air',
    'Send a message to someone safe',
    'Make one task smaller',
    'Rest for five minutes',
  ];

  static const List<Map<String, String>> _groundingSteps = [
    {'count': '5', 'label': 'things you can see'},
    {'count': '4', 'label': 'things you can feel'},
    {'count': '3', 'label': 'things you can hear'},
    {'count': '2', 'label': 'things you can smell'},
    {'count': '1', 'label': 'thing you can taste'},
  ];

  @override
  void initState() {
    super.initState();
    try {
      _copingPlan = StorageService.getCopingPlan();
    } catch (_) {
      _copingPlan = [];
    }
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
    _situationController.dispose();
    _thoughtController.dispose();
    _balancedThoughtController.dispose();
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
            const SizedBox(height: 16),
            _buildSupportTool(
              context: context,
              primary: primary,
              title: 'Untangle a difficult thought',
              subtitle: 'Make room between what happened and what your mind is saying.',
              icon: Icons.psychology_alt_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _reflectionField(
                    controller: _situationController,
                    label: 'What happened?',
                    hint: 'Describe only the part that matters right now.',
                  ),
                  const SizedBox(height: 10),
                  _reflectionField(
                    controller: _thoughtController,
                    label: 'What are you telling yourself about it?',
                    hint: 'Notice the thought without judging yourself.',
                  ),
                  const SizedBox(height: 10),
                  _reflectionField(
                    controller: _balancedThoughtController,
                    label: 'What is a kinder, more balanced possibility?',
                    hint: 'What would you say to a friend in the same situation?',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You do not have to force a positive thought. A little more room for uncertainty is enough.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSupportTool(
              context: context,
              primary: primary,
              title: 'A kinder voice',
              subtitle: 'Try offering yourself the compassion you would give someone you care about.',
              icon: Icons.favorite_border_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kindnessLine(context, 'This is hard for me right now.'),
                  _kindnessLine(context, 'I do not have to solve everything at once.'),
                  _kindnessLine(context, 'I can take one small step, or pause.'),
                  const SizedBox(height: 8),
                  Text(
                    'Choose only the words that feel believable. You can change them to sound like you.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSupportTool(
              context: context,
              primary: primary,
              title: 'Find one manageable next step',
              subtitle: 'You only need to choose what might help for the next few minutes.',
              icon: Icons.spa_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._smallSteps.map(
                    (step) => RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: step,
                      groupValue: _selectedSmallStep,
                      activeColor: primary,
                      title: Text(step, style: Theme.of(context).textTheme.bodyMedium),
                      onChanged: (value) => setState(() {
                        _selectedSmallStep = value ?? '';
                      }),
                    ),
                  ),
                  if (_selectedSmallStep.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'For now: $_selectedSmallStep. That is enough to begin; you can change your mind at any time.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final updated = [..._copingPlan, _selectedSmallStep].toSet().toList();
                        try {
                          await StorageService.saveCopingPlan(updated);
                          if (mounted) {
                            setState(() => _copingPlan = updated);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to your personal coping plan.')),
                            );
                          }
                        } catch (error) {
                          debugPrint('CalmMomentSheet: coping plan save failed: $error');
                        }
                      },
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Save to my coping plan'),
                    ),
                  ],
                  if (_copingPlan.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('Your personal coping plan', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    ..._copingPlan.map(
                      (step) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.check_circle_outline_rounded, color: primary),
                        title: Text(step),
                        trailing: IconButton(
                          tooltip: 'Remove from coping plan',
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () async {
                            final updated = _copingPlan.where((item) => item != step).toList();
                            try {
                              await StorageService.saveCopingPlan(updated);
                              if (mounted) setState(() => _copingPlan = updated);
                            } catch (error) {
                              debugPrint('CalmMomentSheet: coping plan update failed: $error');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTool({
    required BuildContext context,
    required Color primary,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.35)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          leading: Icon(icon, color: primary),
          title: Text(title, style: theme.textTheme.titleMedium),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitle, style: theme.textTheme.bodySmall),
          ),
          children: [child],
        ),
      ),
    );
  }

  Widget _reflectionField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _kindnessLine(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 19, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
