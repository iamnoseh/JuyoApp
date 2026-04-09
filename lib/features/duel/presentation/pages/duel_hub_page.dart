import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class DuelHubPage extends StatefulWidget {
  const DuelHubPage({super.key});

  @override
  State<DuelHubPage> createState() => _DuelHubPageState();
}

class _DuelHubPageState extends State<DuelHubPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.duelTitle,
      subtitle: l10n.duelSubtitle,
      child: Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Realtime duel transport is the next integration slice. Public invite routing is already ready.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  label: l10n.duelCreateInvite,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.commonSoon)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.duelInviteCodeLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: l10n.duelInviteCodeLabel,
                  hint: 'ABCD-1234',
                  controller: _codeController,
                  prefixIcon: Icons.key_rounded,
                ),
                const SizedBox(height: 16),
                AppSecondaryButton(
                  label: l10n.duelJoinButton,
                  onPressed: () {
                    final code = _codeController.text.trim();
                    if (code.isEmpty) return;
                    context.push('${AppRoutes.duelInvite}/$code');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
