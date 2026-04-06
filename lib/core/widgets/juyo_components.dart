import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/core/theme/app_theme.dart';

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSlate : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                fontSize: 14,
              ),
              prefixIcon: icon != null 
                ? Icon(icon, size: 18, color: AppColors.slate) 
                : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.aqua, width: 2),
              ),
            ),
          ),
        ),
      ],
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = isSecondary 
        ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08))
        : AppColors.gold;
    
    Color fgColor = isSecondary 
        ? (isDark ? AppColors.aqua : Colors.black87) 
        : Colors.black;

    if (isDanger) {
      bgColor = Colors.red.withValues(alpha: 0.15);
      fgColor = Colors.redAccent;
    }

    return Container(
      width: double.infinity,
      height: 50,
      decoration: (isSecondary || isDanger) ? null : BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: (isSecondary || isDanger) ? bgColor : Colors.transparent,
          foregroundColor: fgColor,
          shadowColor: Colors.transparent,
          side: isDanger ? const BorderSide(color: Colors.redAccent, width: 1) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: fgColor),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.1),
              ),
      ),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3545),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              JuyoBadge(
                icon: LucideIcons.flame,
                text: '$streak',
                color: Colors.orangeAccent,
              ),
              const Text(
                'JUYO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                ),
              ),
              JuyoBadge(
                icon: LucideIcons.coins,
                text: '$points',
                color: AppColors.gold,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
