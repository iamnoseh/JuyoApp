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
    return Scaffold(
      extendBody: true,
      body: AuroraBackground(child: child),
      bottomNavigationBar: AppBottomNav(
        activeTab: _activeTabForLocation(location),
        onTap: (tab) {
          switch (tab) {
            case AppShellTab.dashboard:
              context.go(AppRoutes.dashboard);
            case AppShellTab.duel:
              context.go(AppRoutes.duel);
            case AppShellTab.tests:
              context.go(AppRoutes.tests);
            case AppShellTab.league:
              context.go(AppRoutes.league);
            case AppShellTab.profile:
              context.go(AppRoutes.profile);
          }
        },
      ),
    );
  }

  AppShellTab _activeTabForLocation(String path) {
    if (path.startsWith(AppRoutes.duel)) return AppShellTab.duel;
    if (path.startsWith(AppRoutes.tests)) return AppShellTab.tests;
    if (path.startsWith(AppRoutes.league)) return AppShellTab.league;
    if (path.startsWith(AppRoutes.profile)) return AppShellTab.profile;
    return AppShellTab.dashboard;
  }
}
