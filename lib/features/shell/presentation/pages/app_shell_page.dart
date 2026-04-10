import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/core/widgets/aurora_background.dart';

class AppShellPage extends StatelessWidget {
  final String location;
  final Widget child;

  const AppShellPage({
    super.key,
    required this.location,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottomNav = AppTelegramBottomNav(
      activeTab: _activeTabForLocation(location),
      onMenuTap: () => showAppQuickMenuSheet(context),
      onTap: (tab) {
        if (tab == AppShellTab.dashboard) {
          context.go(AppRoutes.dashboard);
          return;
        }
        if (tab == AppShellTab.tests) {
          context.go(AppRoutes.tests);
          return;
        }
        if (tab == AppShellTab.menu) {
          showAppQuickMenuSheet(context);
          return;
        }
        if (tab == AppShellTab.league) {
          context.go(AppRoutes.league);
          return;
        }
        context.go(AppRoutes.profile);
      },
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AuroraBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey(location),
                child: child,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottomNav,
            ),
          ],
        ),
      ),
    );
  }

  AppShellTab _activeTabForLocation(String path) {
    if (path.startsWith(AppRoutes.profile)) return AppShellTab.profile;
    if (path.startsWith(AppRoutes.practice)) return AppShellTab.tests;
    if (path.startsWith(AppRoutes.league)) return AppShellTab.league;
    if (path.startsWith(AppRoutes.tests)) return AppShellTab.tests;
    if (path.startsWith(AppRoutes.duel) ||
        path.startsWith(AppRoutes.premium) ||
        path.startsWith(AppRoutes.referral) ||
        path.startsWith(AppRoutes.redList) ||
        path.startsWith(AppRoutes.schoolLeaderboard)) {
      return AppShellTab.menu;
    }
    return AppShellTab.dashboard;
  }
}
