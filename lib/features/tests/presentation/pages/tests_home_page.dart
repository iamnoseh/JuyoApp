import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class TestsHomePage extends StatefulWidget {
  const TestsHomePage({super.key});

  @override
  State<TestsHomePage> createState() => _TestsHomePageState();
}

class _TestsHomePageState extends State<TestsHomePage> {
  bool _loading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiClient.dio.get('/User/profile');
      final body = response.data is Map ? response.data['data'] ?? response.data : {};
      final premium = body is Map ? body['isPremium'] ?? body['IsPremium'] : false;
      setState(() {
        _isPremium = premium == true;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      topBar: const AppTopStatsBar(),
      title: l10n.testsTitle,
      subtitle: l10n.testsSubtitle,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.aqua))
          : Column(
              children: [
                _ModeCard(
                  title: l10n.testsPracticeMode,
                  subtitle: _modeSubtitle(
                    context,
                    ru: 'Тренировка по кластерам с быстрым стартом',
                    en: 'Cluster-based practice with a quick start',
                  ),
                  icon: Icons.auto_graph_rounded,
                  color: AppColors.aqua,
                  onTap: () => _guardedNavigate(
                    locked: !_isPremium,
                    path: AppRoutes.practice,
                  ),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  title: l10n.testsExamMode,
                  subtitle: _modeSubtitle(
                    context,
                    ru: 'Режим, похожий на реальный экзамен',
                    en: 'Simulation mode close to the real exam',
                  ),
                  icon: Icons.school_rounded,
                  color: AppColors.gold,
                  onTap: () => _guardedNavigate(
                    locked: !_isPremium,
                    path: AppRoutes.exam,
                  ),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  title: l10n.testsDuelMode,
                  subtitle: _modeSubtitle(
                    context,
                    ru: 'Живые дуэли и приватные приглашения',
                    en: 'Live duels and private invites',
                  ),
                  icon: Icons.flash_on_rounded,
                  color: AppColors.emerald,
                  onTap: () => _guardedNavigate(
                    locked: !_isPremium,
                    path: AppRoutes.duel,
                  ),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  title: l10n.testsSubjectMode,
                  subtitle: _modeSubtitle(
                    context,
                    ru: 'Выберите предмет и начните точечную тренировку',
                    en: 'Choose one subject and practice deeply',
                  ),
                  icon: Icons.menu_book_rounded,
                  color: AppColors.textPrimary,
                  onTap: () => context.push(AppRoutes.subjectTests),
                ),
              ],
            ),
    );
  }

  Future<void> _guardedNavigate({
    required bool locked,
    required String path,
  }) async {
    final l10n = context.l10n;
    if (locked) {
      await showLockedFeatureSheet(
        context,
        title: l10n.lockedTitle,
        subtitle: l10n.lockedSubtitle,
        onOpenPremium: () => context.push(AppRoutes.premium),
      );
      return;
    }
    if (!mounted) return;
    context.push(path);
  }
}

String _modeSubtitle(
  BuildContext context, {
  required String ru,
  required String en,
}) {
  return Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF475569),
          ),
        ],
      ),
    );
  }
}
