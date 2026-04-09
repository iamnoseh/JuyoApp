import 'package:flutter/material.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/core/l10n/locale_controller.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/theme/theme_mode_controller.dart';

enum AppShellTab { dashboard, duel, tests, league, profile }

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    final content = Container(
      decoration: BoxDecoration(
        color: palette.glass,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: palette.cardStroke),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: content,
        ),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), AppColors.gold],
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(color: palette.border),
          backgroundColor: palette.secondaryFill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final bool enableSuggestions;
  final bool autocorrect;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.maxLength,
    this.autofillHints,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: secondaryText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          maxLines: 1,
          minLines: 1,
          expands: false,
          textAlignVertical: TextAlignVertical.center,
          autofillHints: autofillHints,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          textInputAction: textInputAction,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: secondaryText, size: 18),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class OtpField extends StatelessWidget {
  final TextEditingController controller;

  const OtpField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: '',
      hint: '0000',
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 4,
    );
  }
}

class StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const StatChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.hourglass_empty_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).textTheme.bodyMedium?.color;

    return GlassCard(
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 34, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            AppSecondaryButton(
              label: 'Retry',
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 20),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: title,
              subtitle: subtitle,
              trailing: trailing,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (scrollable)
              Expanded(child: SingleChildScrollView(child: child))
            else
              Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final AppShellTab activeTab;
  final ValueChanged<AppShellTab> onTap;

  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final inactiveColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: palette.navSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                label: 'Home',
                icon: Icons.grid_view_rounded,
                active: activeTab == AppShellTab.dashboard,
                inactiveColor: inactiveColor,
                onTap: () => onTap(AppShellTab.dashboard),
              ),
              _NavItem(
                label: 'Duel',
                icon: Icons.flash_on_rounded,
                active: activeTab == AppShellTab.duel,
                inactiveColor: inactiveColor,
                onTap: () => onTap(AppShellTab.duel),
              ),
              _NavItem(
                label: 'Tests',
                icon: Icons.menu_book_rounded,
                active: activeTab == AppShellTab.tests,
                inactiveColor: inactiveColor,
                onTap: () => onTap(AppShellTab.tests),
              ),
              _NavItem(
                label: 'League',
                icon: Icons.emoji_events_rounded,
                active: activeTab == AppShellTab.league,
                inactiveColor: inactiveColor,
                onTap: () => onTap(AppShellTab.league),
              ),
              _NavItem(
                label: 'Profile',
                icon: Icons.person_rounded,
                active: activeTab == AppShellTab.profile,
                inactiveColor: inactiveColor,
                onTap: () => onTap(AppShellTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppColors.gold : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: active ? AppColors.gold : inactiveColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppThemeModeButton extends StatelessWidget {
  final bool compact;

  const AppThemeModeButton({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt<ThemeModeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.appPalette;
    final buttonSize = compact ? 36.0 : 40.0;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton(
        onPressed: controller.toggle,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: palette.secondaryFill,
          side: BorderSide(color: palette.border),
        ),
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: compact ? 18 : 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class AppLanguageButton extends StatelessWidget {
  final bool compact;

  const AppLanguageButton({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt<LocaleController>();
    final palette = context.appPalette;
    final currentCode = switch (controller.locale.languageCode) {
      'tg' => 'TJ',
      'ru' => 'RU',
      'en' => 'EN',
      _ => 'TJ',
    };
    final height = compact ? 36.0 : 40.0;
    final horizontalPadding = compact ? 10.0 : 12.0;

    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: () {
          final nextLocale = switch (controller.locale.languageCode) {
            'tg' => const Locale('ru'),
            'ru' => const Locale('en'),
            _ => const Locale('tg'),
          };
          controller.setLocale(nextLocale);
        },
        style: TextButton.styleFrom(
          backgroundColor: palette.secondaryFill,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(color: palette.border),
          ),
        ),
        child: Text(
          currentCode,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: compact ? 11 : null,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class AppHeaderActions extends StatelessWidget {
  final bool compact;

  const AppHeaderActions({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLanguageButton(compact: compact),
        SizedBox(width: compact ? 6 : 8),
        AppThemeModeButton(compact: compact),
      ],
    );
  }
}

Future<void> showLockedFeatureSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required VoidCallback onOpenPremium,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 36),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            AppPrimaryButton(
              label: 'Premium',
              onPressed: () {
                Navigator.of(context).pop();
                onOpenPremium();
              },
            ),
          ],
        ),
      );
    },
  );
}
