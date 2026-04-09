import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/core/widgets/aurora_background.dart';

class DuelInvitePage extends StatelessWidget {
  final String inviteCode;

  const DuelInvitePage({
    super.key,
    required this.inviteCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, color: Colors.white, size: 40),
                    const SizedBox(height: 12),
                    Text(l10n.inviteTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      l10n.inviteSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      inviteCode,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    AppPrimaryButton(
                      label: l10n.authSignIn,
                      onPressed: () => context.go(AppRoutes.login),
                    ),
                    const SizedBox(height: 12),
                    AppSecondaryButton(
                      label: l10n.authSignUp,
                      onPressed: () => context.go(AppRoutes.register),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
