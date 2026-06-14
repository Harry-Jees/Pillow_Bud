import 'package:flutter/material.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: Size(width ?? 0, 50),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
