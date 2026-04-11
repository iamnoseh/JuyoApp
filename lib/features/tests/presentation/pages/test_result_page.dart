import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/core/widgets/aurora_background.dart';
import 'package:juyo/features/tests/data/models/test_session_models.dart';
import 'package:juyo/features/tests/data/repositories/test_session_repository.dart';

class TestResultPage extends StatefulWidget {
  final String sessionId;
  final TestSessionResultModel? initialResult;
  final int? elapsedSeconds;

  const TestResultPage({
    super.key,
    required this.sessionId,
    this.initialResult,
    this.elapsedSeconds,
  });

  @override
  State<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {
  final TestSessionRepository _repository = const TestSessionRepository();

  TestSessionResultModel? _result;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialResult != null) {
      _result = widget.initialResult;
      _loading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final result = await _repository.finishTest(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message ?? 'Unable to load result';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: _loading
              ? const JuyoPageLoader()
              : _error != null || _result == null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: ErrorState(
                        title: _t(context, ru: 'Ошибка', en: 'Error'),
                        subtitle: _error ??
                            _t(
                              context,
                              ru: 'Результат недоступен',
                              en: 'Result is unavailable',
                            ),
                        onRetry: _load,
                      ),
                    )
                  : _ResultContent(
                      result: _result!,
                      elapsedSeconds: widget.elapsedSeconds,
                    ),
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final TestSessionResultModel result;
  final int? elapsedSeconds;

  const _ResultContent({
    required this.result,
    required this.elapsedSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final errors = result.totalQuestions - result.correctAnswers;
    final accent = result.percentage >= 70
        ? AppColors.emerald
        : result.percentage >= 45
            ? AppColors.gold
            : AppColors.danger;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          GlassCard(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                    border: Border.all(color: accent.withValues(alpha: 0.18)),
                  ),
                  child: Icon(
                    result.percentage >= 70
                        ? Icons.emoji_events_rounded
                        : Icons.assessment_rounded,
                    color: accent,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _t(context, ru: 'Тест завершен', en: 'Test completed'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _t(
                    context,
                    ru: 'Ваш результат сохранен. Ниже краткая сводка по сессии.',
                    en: 'Your result is saved. Here is a quick session summary.',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: accent.withValues(alpha: 0.16)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${result.percentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: accent,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${result.correctAnswers}/${result.totalQuestions}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ResultStat(
                label: _t(context, ru: 'Верно', en: 'Correct'),
                value: '${result.correctAnswers}',
                color: AppColors.emerald,
              ),
              _ResultStat(
                label: _t(context, ru: 'Ошибки', en: 'Errors'),
                value: '$errors',
                color: AppColors.danger,
              ),
              _ResultStat(
                label: 'XP',
                value: '+${result.xpEarned}',
                color: AppColors.gold,
              ),
              _ResultStat(
                label: _t(context, ru: 'Время', en: 'Time'),
                value: elapsedSeconds == null ? '--:--' : _formatTime(elapsedSeconds!),
                color: AppColors.aqua,
              ),
            ],
          ),
          if ((result.aiAnalysis ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(context, ru: 'AI-анализ', en: 'AI analysis'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result.aiAnalysis!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppPrimaryButton(
            label: _t(context, ru: 'К тестам', en: 'Back to tests'),
            onPressed: () => context.go(AppRoutes.tests),
          ),
          const SizedBox(height: 10),
          AppSecondaryButton(
            label: _t(context, ru: 'На главную', en: 'Go home'),
            onPressed: () => context.go(AppRoutes.dashboard),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 2 - 22;
    return SizedBox(
      width: width,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

String _t(BuildContext context, {required String ru, required String en}) {
  return Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
}

String _formatTime(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}
