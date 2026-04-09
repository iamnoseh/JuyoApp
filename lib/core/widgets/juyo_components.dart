import 'package:flutter/material.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';

export 'package:juyo/core/widgets/app_ui.dart';

class JuyoInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const JuyoInput({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      prefixIcon: icon,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
    );
  }
}

class JuyoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isDanger;

  const JuyoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDanger) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger.withValues(alpha: 0.16),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            side: const BorderSide(color: AppColors.danger),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Text(text),
        ),
      );
    }

    if (isSecondary) {
      return AppSecondaryButton(label: text, onPressed: onPressed);
    }

    return AppPrimaryButton(
      label: text,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}

class JuyoStickyHeader extends StatelessWidget {
  final int streak;
  final int points;

  const JuyoStickyHeader({
    super.key,
    required this.streak,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: JuyoBadge(
                  icon: Icons.local_fire_department_rounded,
                  text: '$streak',
                  color: AppColors.gold,
                ),
              ),
              Text(
                'JUYO',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      letterSpacing: 3,
                    ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: JuyoBadge(
                    icon: Icons.bolt_rounded,
                    text: '$points',
                    color: AppColors.aqua,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JuyoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const JuyoBadge({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
