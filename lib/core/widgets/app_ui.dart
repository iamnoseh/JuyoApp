import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/core/l10n/locale_controller.dart';
import 'package:juyo/core/network/api_client.dart';
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
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
        ),
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
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.16)
                : const Color(0xFFD7DEE8),
          ),
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          elevation: 0,
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

class JuyoPageLoader extends StatelessWidget {
  final String? message;

  const JuyoPageLoader({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'JUYO',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: 6,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 14),
          const _JuyoLoadingDots(),
        ],
      ),
    );
  }
}

class _JuyoLoadingDots extends StatefulWidget {
  const _JuyoLoadingDots();

  @override
  State<_JuyoLoadingDots> createState() => _JuyoLoadingDotsState();
}

class _JuyoLoadingDotsState extends State<_JuyoLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final shifted = (_controller.value - index * 0.16) % 1.0;
            final active = shifted < 0.45;
            final scale = active ? 1.12 : 0.72;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              transform: Matrix4.identity()..scale(scale),
              decoration: BoxDecoration(
                color: AppColors.aqua.withValues(alpha: active ? 0.95 : 0.28),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
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
    final contentTopOffset = topBar == null ? 0.0 : 48.0;
    const bottomOverlaySpace = 104.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contentTopOffset > 0) SizedBox(height: contentTopOffset),
                if (showHeader) ...[
                  SectionHeader(
                    title: title,
                    subtitle: subtitle,
                    trailing: trailing,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (scrollable)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: bottomOverlaySpace),
                      child: child,
                    ),
                  )
                else
                  Expanded(
                    child: child,
                  ),
              ],
            ),
          ),
        ),
        if (topBar != null)
          Positioned(
            left: 16,
            right: 16,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: topBar!,
            ),
          ),
      ],
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

class AppGlassBottomNav extends StatelessWidget {
  final AppShellTab activeTab;
  final ValueChanged<AppShellTab> onTap;
  final VoidCallback onMenuTap;

  const AppGlassBottomNav({
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
    final activeIndex = _indexForTab(activeTab);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 78,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.13),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.76),
                          Colors.white.withValues(alpha: 0.50),
                        ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.07 : 0.44),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 5;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeOutBack,
                        left: itemWidth * activeIndex + 5,
                        top: 5,
                        bottom: 5,
                        width: itemWidth - 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gold.withValues(alpha: 0.24),
                                AppColors.aqua.withValues(alpha: 0.10),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.16),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
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
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _indexForTab(AppShellTab tab) {
    return switch (tab) {
      AppShellTab.dashboard => 0,
      AppShellTab.tests => 1,
      AppShellTab.menu => 2,
      AppShellTab.league => 3,
      AppShellTab.profile => 4,
    };
  }
}

class AppTelegramBottomNav extends StatelessWidget {
  final AppShellTab activeTab;
  final ValueChanged<AppShellTab> onTap;
  final VoidCallback onMenuTap;

  const AppTelegramBottomNav({
    super.key,
    required this.activeTab,
    required this.onTap,
    required this.onMenuTap,
  });

  static const Color _navInk = Color(0xFF0B1220);
  static const Color _navStroke = Color(0x1FFFFFFF);

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.62)
        : const Color(0xFF475569);
    const activeColor = AppColors.gold;
    final activeIndex = _indexForTab(activeTab);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? _navInk.withValues(alpha: 0.56)
                    : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.86),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 5;

                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        left: itemWidth * activeIndex,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.11)
                                      : Colors.white.withValues(alpha: 0.82),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: isDark ? 0.14 : 0.92,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.10 : 0.05,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _TelegramNavItem(
                            label: isRu ? 'Главная' : 'Home',
                            icon: Icons.grid_view_rounded,
                            active: activeTab == AppShellTab.dashboard,
                            activeTextColor: activeColor,
                            inactiveColor: inactiveColor,
                            onTap: () => onTap(AppShellTab.dashboard),
                          ),
                          _TelegramNavItem(
                            label: isRu ? 'Тесты' : 'Tests',
                            icon: Icons.menu_book_rounded,
                            active: activeTab == AppShellTab.tests,
                            activeTextColor: activeColor,
                            inactiveColor: inactiveColor,
                            onTap: () => onTap(AppShellTab.tests),
                          ),
                          _TelegramNavItem(
                            label: isRu ? 'Меню' : 'Menu',
                            icon: Icons.apps_rounded,
                            active: activeTab == AppShellTab.menu,
                            activeTextColor: activeColor,
                            inactiveColor: inactiveColor,
                            onTap: onMenuTap,
                          ),
                          _TelegramNavItem(
                            label: isRu ? 'Лига' : 'League',
                            icon: Icons.emoji_events_rounded,
                            active: activeTab == AppShellTab.league,
                            activeTextColor: activeColor,
                            inactiveColor: inactiveColor,
                            onTap: () => onTap(AppShellTab.league),
                          ),
                          _TelegramNavItem(
                            label: isRu ? 'Профиль' : 'Profile',
                            icon: Icons.person_rounded,
                            active: activeTab == AppShellTab.profile,
                            activeTextColor: activeColor,
                            inactiveColor: inactiveColor,
                            onTap: () => onTap(AppShellTab.profile),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _indexForTab(AppShellTab tab) {
    return switch (tab) {
      AppShellTab.dashboard => 0,
      AppShellTab.tests => 1,
      AppShellTab.menu => 2,
      AppShellTab.league => 3,
      AppShellTab.profile => 4,
    };
  }
}

class _TelegramNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeTextColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _TelegramNavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeTextColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeTextColor : inactiveColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedScale(
          scale: active ? 1.02 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: active ? 22 : 20, color: color),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: color,
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        height: 1,
                        letterSpacing: 0,
                      ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.72),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFE2E8F0),
              ),
              minimumSize: Size(buttonSize, buttonSize),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: compact ? 18 : 20,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.90),
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
    final horizontalPadding = compact ? 11.0 : 12.0;

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
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.72),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFE2E8F0),
              ),
              minimumSize: Size(0, height),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              currentCode,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: compact ? 11 : null,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.90),
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

class AppTopStatsBar extends StatefulWidget {
  final int? totalXp;
  final int? streak;

  const AppTopStatsBar({
    super.key,
    this.totalXp,
    this.streak,
  });

  @override
  State<AppTopStatsBar> createState() => _AppTopStatsBarState();
}

class _AppTopStatsBarState extends State<AppTopStatsBar> {
  late Future<_TopStatsSnapshot> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  @override
  void didUpdateWidget(covariant AppTopStatsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalXp != widget.totalXp || oldWidget.streak != widget.streak) {
      _statsFuture = _loadStats();
    }
  }

  Future<_TopStatsSnapshot> _loadStats() async {
    if (widget.totalXp != null && widget.streak != null && widget.streak! > 0) {
      return _TopStatsSnapshot(
        xp: widget.totalXp ?? 0,
        streak: widget.streak ?? 0,
      );
    }

    var xp = widget.totalXp ?? 0;
    var streak = widget.streak ?? 0;

    try {
      final response = await ApiClient.dio.get('/User/profile');
      final body = response.data;
      final data = body is Map ? (body['data'] ?? body) : body;

      if (data is Map) {
        xp = widget.totalXp ?? _readInt(data, const ['xp', 'XP', 'points', 'Points']);
        streak = widget.streak != null && widget.streak! > 0
            ? widget.streak!
            : _readInt(
                data,
                const [
                  'streak',
                  'Streak',
                  'currentStreak',
                  'CurrentStreak',
                  'dailyStreak',
                  'DailyStreak',
                ],
              );
      }
    } catch (_) {}

    if (streak <= 0) {
      try {
        final response = await ApiClient.dio.get('/User/activity');
        final body = response.data;
        final data = body is Map ? (body['data'] ?? body) : body;
        if (data is Map) {
          streak = _readInt(
            data,
            const ['currentStreak', 'CurrentStreak', 'streak', 'Streak'],
          );
        }
      } catch (_) {}
    }

    return _TopStatsSnapshot(xp: xp, streak: streak);
  }

  int _readInt(Map<dynamic, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      if (value is int) return value;
      final parsed = int.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TopStatsSnapshot>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? const _TopStatsSnapshot(xp: 0, streak: 0);

        return SizedBox(
          height: 42,
          child: Row(
            children: [
              const AppLanguageButton(compact: true),
              const SizedBox(width: 14),
              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      _TopStatPill(
                        icon: Icons.bolt_rounded,
                        label: '${stats.xp} XP',
                        color: AppColors.gold,
                      ),
                      _TopStatPill(
                        icon: Icons.local_fire_department_rounded,
                        label: '${stats.streak}',
                        color: AppColors.emerald,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const AppThemeModeButton(compact: true),
            ],
          ),
        );
      },
    );
  }
}

class _TopStatsSnapshot {
  final int xp;
  final int streak;

  const _TopStatsSnapshot({
    required this.xp,
    required this.streak,
  });
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
    final textColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.88);

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
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.95)),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1,
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
      shellRoute: true,
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
      shellRoute: true,
    ),
    _QuickMenuItem(
      label: isRu ? 'Пригласить друга' : 'Invite a Friend',
      icon: Icons.card_giftcard_rounded,
      route: AppRoutes.referral,
      shellRoute: true,
    ),
    const _QuickMenuItem(
      label: 'Premium',
      icon: Icons.workspace_premium_rounded,
      route: AppRoutes.premium,
      shellRoute: true,
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
