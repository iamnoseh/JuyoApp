import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/core/l10n/locale_controller.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/theme/theme_mode_controller.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_event.dart';

enum AppShellTab { dashboard, tests, menu, league, profile }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ]
              : [
                  Colors.white.withValues(alpha: 0.94),
                  Colors.white.withValues(alpha: 0.78),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: isDark ? 0.46 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.02 : 0.6),
            blurRadius: 8,
            offset: const Offset(0, -1),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.0)),
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.82),
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
        SizedBox(
          height: 56,
          child: TextFormField(
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
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              height: 1.15,
              leading: 0,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              hintText: hint,
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, color: secondaryText, size: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 42,
              ),
              suffixIcon: suffix,
            ),
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
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
  final Widget? topBar;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final bool showHeader;

  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.trailing,
    this.topBar,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 20),
    this.scrollable = true,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (topBar != null) ...[
              topBar!,
              const SizedBox(height: AppSpacing.lg),
            ],
            if (showHeader) ...[
              SectionHeader(
                title: title,
                subtitle: subtitle,
                trailing: trailing,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
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
  final VoidCallback onMenuTap;

  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final inactiveColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.11),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.92),
                      Colors.white.withValues(alpha: 0.78),
                    ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.02 : 0.65),
                blurRadius: 8,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                label: isRu ? 'Главная' : 'Home',
                icon: Icons.grid_view_rounded,
                active: activeTab == AppShellTab.dashboard,
                inactiveColor: inactiveColor,
                onTap: () => onTap(AppShellTab.dashboard),
              ),
              _NavItem(
                label: isRu ? 'Тесты' : 'Tests',
                icon: Icons.menu_book_rounded,
                active: activeTab == AppShellTab.tests,
                inactiveColor: inactiveColor,
                onTap: () => onTap(AppShellTab.tests),
              ),
              _CenterMenuButton(
                active: activeTab == AppShellTab.menu,
                onTap: onMenuTap,
                label: isRu ? 'Меню' : 'Menu',
              ),
              _NavItem(
                label: isRu ? 'Лига' : 'League',
                icon: Icons.emoji_events_rounded,
                active: activeTab == AppShellTab.league,
                inactiveColor: inactiveColor,
                onTap: () => onTap(AppShellTab.league),
              ),
              _NavItem(
                label: isRu ? 'Профиль' : 'Profile',
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

class _CenterMenuButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  final String label;

  const _CenterMenuButton({
    required this.active,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFFF97316), AppColors.gold],
                      )
                    : null,
                color: active
                    ? null
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.74)),
                borderRadius: BorderRadius.circular(999),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.24),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.apps_rounded,
                size: 22,
                color: active ? Colors.white : inactiveColor,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.68))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
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
    final buttonSize = compact ? 36.0 : 40.0;

      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return SizedBox(
            width: buttonSize,
            height: buttonSize,
          child: IconButton(
            onPressed: controller.toggle,
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.88),
            ),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: compact ? 18 : 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      },
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
    final height = compact ? 36.0 : 40.0;
    final horizontalPadding = compact ? 10.0 : 12.0;

      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final currentCode = switch (controller.locale.languageCode) {
            'ru' => 'RU',
            'en' => 'EN',
            _ => 'RU',
        };

        return SizedBox(
          height: height,
          child: TextButton(
            onPressed: () {
              final nextLocale = switch (controller.locale.languageCode) {
                'ru' => const Locale('en'),
                _ => const Locale('ru'),
              };
              controller.setLocale(nextLocale);
            },
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.88),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
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
      },
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

class AppTopStatsBar extends StatelessWidget {
  final int totalXp;
  final int streak;

  const AppTopStatsBar({
    super.key,
    this.totalXp = 2140,
    this.streak = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLanguageButton(compact: true),
        const SizedBox(width: 12),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _TopStatPill(
                  icon: Icons.bolt_rounded,
                  label: '$totalXp XP',
                  color: AppColors.gold,
                ),
                _TopStatPill(
                  icon: Icons.local_fire_department_rounded,
                  label: '$streak',
                  color: AppColors.emerald,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const AppThemeModeButton(compact: true),
      ],
    );
  }
}

class _TopStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TopStatPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickMenuItem {
  final String label;
  final IconData icon;
  final String? route;
  final bool shellRoute;
  final bool isLogout;

  const _QuickMenuItem({
    required this.label,
    required this.icon,
    this.route,
    this.shellRoute = false,
    this.isLogout = false,
  });
}

Future<void> showAppQuickMenuSheet(BuildContext context) {
  final isRu = Localizations.localeOf(context).languageCode == 'ru';
  final palette = context.appPalette;
  final router = GoRouter.of(context);
  final items = [
    _QuickMenuItem(
      label: isRu ? 'Дуэль' : 'Duel',
      icon: Icons.flash_on_rounded,
      route: AppRoutes.duel,
      shellRoute: true,
    ),
    _QuickMenuItem(
      label: isRu ? 'Тесты' : 'Tests',
      icon: Icons.psychology_alt_rounded,
      route: AppRoutes.tests,
      shellRoute: true,
    ),
    _QuickMenuItem(
      label: isRu ? 'Красный список' : 'Red List',
      icon: Icons.local_fire_department_outlined,
      route: AppRoutes.redList,
    ),
    _QuickMenuItem(
      label: isRu ? 'Рейтинг лиги' : 'League Ranking',
      icon: Icons.bar_chart_rounded,
      route: AppRoutes.league,
      shellRoute: true,
    ),
    _QuickMenuItem(
      label: isRu ? 'Рейтинг школ' : 'School Ranking',
      icon: Icons.school_outlined,
      route: AppRoutes.schoolLeaderboard,
    ),
    _QuickMenuItem(
      label: isRu ? 'Пригласить друга' : 'Invite a Friend',
      icon: Icons.card_giftcard_rounded,
      route: AppRoutes.referral,
    ),
    const _QuickMenuItem(
      label: 'Premium',
      icon: Icons.workspace_premium_rounded,
      route: AppRoutes.premium,
    ),
    _QuickMenuItem(
      label: isRu ? 'Выйти' : 'Logout',
      icon: Icons.logout_rounded,
      isLogout: true,
    ),
  ];

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'quick-menu',
    barrierColor: Colors.black.withValues(alpha: 0.36),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, __) {
      final height = MediaQuery.of(dialogContext).size.height * 0.52;
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            height: height,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: Theme.of(dialogContext).brightness == Brightness.dark
                    ? [
                        const Color(0xFF101826),
                        const Color(0xFF0B1220),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF7FAFF),
                      ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              itemBuilder: (itemContext, index) {
                final item = items[index];
                final iconColor = item.isLogout
                    ? AppColors.danger
                    : item.route == AppRoutes.premium
                    ? AppColors.gold
                    : Theme.of(itemContext).textTheme.bodyMedium?.color;

                return InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    if (item.isLogout) {
                      getIt<AuthBloc>().add(const AuthLoggedOut());
                      router.go(AppRoutes.login);
                      return;
                    }
                    if (item.route == null) {
                      return;
                    }
                    if (item.shellRoute) {
                      router.go(item.route!);
                    } else {
                      router.push(item.route!);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        Icon(item.icon, size: 22, color: iconColor),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.label,
                            style: Theme.of(itemContext).textTheme.bodyLarge,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: palette.border.withValues(alpha: 0.18),
              ),
              itemCount: items.length,
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.16),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
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
