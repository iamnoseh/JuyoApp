import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/red_list/data/models/red_list_dashboard_model.dart';
import 'package:juyo/features/red_list/data/repositories/red_list_repository.dart';

class RedListStudentPage extends StatefulWidget {
  const RedListStudentPage({super.key});

  @override
  State<RedListStudentPage> createState() => _RedListStudentPageState();
}

class _RedListStudentPageState extends State<RedListStudentPage> {
  final RedListRepository _repository = const RedListRepository();

  bool _loading = true;
  bool _locked = false;
  String? _error;
  RedListDashboardModel? _dashboard;
  final Map<int, String> _explanations = <int, String>{};
  final Map<int, bool> _explanationLoading = <int, bool>{};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _locked = false;
      _error = null;
    });

    try {
      final dashboard = await _repository.getDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      if (isRedListLockedError(error)) {
        setState(() {
          _locked = true;
          _loading = false;
        });
        return;
      }

      setState(() {
        _error = error.response?.data is Map
            ? (error.response?.data['message']?.toString() ?? error.message)
            : error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _fetchExplanation(RedListQuestionModel question) async {
    final existing = _explanations[question.id];
    if (existing != null && existing.trim().isNotEmpty) {
      setState(() {
        _explanations[question.id] = existing;
      });
      return;
    }

    setState(() => _explanationLoading[question.id] = true);

    try {
      final explanation = await _repository.explainQuestion(question.questionId);
      if (!mounted) return;
      setState(() {
        _explanations[question.id] = explanation;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      final message = error.response?.data is Map
          ? (error.response?.data['message']?.toString() ?? error.message)
          : error.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ??
                _tr(
                  context,
                  'Не удалось получить объяснение ИИ',
                  'Could not fetch AI explanation',
                ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              'Не удалось получить объяснение ИИ',
              'Could not fetch AI explanation',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _explanationLoading.remove(question.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      topBar: const AppTopStatsBar(),
      title: '',
      showHeader: false,
      scrollable: false,
      child: RefreshIndicator(
        color: AppColors.aqua,
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 104),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            _RedListHero(
              title: l10n.commonRedList,
              subtitle: _tr(
                context,
                'Вопросы, которым нужно больше внимания. Практикуйтесь ежедневно, чтобы очищать список и укреплять слабые темы.',
                'Questions that need more attention. Practice daily to clear your list and strengthen weak topics.',
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.56,
                child: const JuyoPageLoader(),
              )
            else if (_locked)
              _RedListLockedState(
                onOpenPremium: () => context.go(AppRoutes.premium),
              )
            else if (_error != null)
              ErrorState(
                title: l10n.errorTitle,
                subtitle: _error,
                onRetry: _loadData,
              )
            else if (_dashboard != null) ...[
              _RedListStatsGrid(stats: _dashboard!.stats),
              const SizedBox(height: 14),
              _RedListChartCard(points: _dashboard!.chartData),
              const SizedBox(height: 14),
              _QuestionsSection(
                questions: _dashboard!.activeQuestions,
                explanations: _explanations,
                explanationLoading: _explanationLoading,
                onAskAi: _fetchExplanation,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RedListHero extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RedListHero({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.danger,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _tr(context, 'Зона усиления', 'Focus zone'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.72),
                ),
          ),
        ],
      ),
    );
  }
}

class _RedListStatsGrid extends StatelessWidget {
  final RedListStatsModel stats;

  const _RedListStatsGrid({
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _RedStatCard(
                title: _tr(context, 'В списке', 'In list'),
                value: '${stats.totalQuestions}',
                hint: _tr(
                  context,
                  '+${stats.newQuestionsToday} сегодня',
                  '+${stats.newQuestionsToday} today',
                ),
                color: AppColors.danger,
                icon: Icons.local_fire_department_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RedStatCard(
                title: _tr(context, 'XP сегодня', 'XP today'),
                value: '${stats.xpToday}',
                hint: _tr(
                  context,
                  '+${stats.xpIncreasePercent}% за день',
                  '+${stats.xpIncreasePercent}% for the day',
                ),
                color: AppColors.gold,
                icon: Icons.bolt_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _RedStatCard(
          title: _tr(context, 'Прогресс очистки', 'Clear progress'),
          value: '${stats.removedTodayCount}',
          hint: _tr(
            context,
            '${stats.readyToRemoveCount} готовы к удалению',
            '${stats.readyToRemoveCount} ready to remove',
          ),
          color: AppColors.aqua,
          icon: Icons.check_circle_rounded,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _RedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String hint;
  final Color color;
  final IconData icon;
  final bool fullWidth;

  const _RedStatCard({
    required this.title,
    required this.value,
    required this.hint,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: fullWidth ? 52 : 48,
            height: fullWidth ? 52 : 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.60),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color.withValues(alpha: 0.92),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RedListChartCard extends StatelessWidget {
  final List<RedListChartPointModel> points;

  const _RedListChartCard({
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RedSectionTitle(
            title: _tr(context, 'Ежедневная динамика', 'Daily momentum'),
            icon: Icons.show_chart_rounded,
            color: AppColors.aqua,
          ),
          const SizedBox(height: 14),
          if (points.isEmpty)
            EmptyState(
              title: _tr(context, 'Пока нет данных для графика', 'No chart data yet'),
              subtitle: _tr(
                context,
                'Когда появится история добавлений и удалений, здесь будет видна динамика.',
                'When there is add/remove history, the trend will appear here.',
              ),
              icon: Icons.insights_outlined,
            )
          else
            SizedBox(
              height: 240,
              child: _RedListChart(points: points),
            ),
        ],
      ),
    );
  }
}

class _RedListChart extends StatelessWidget {
  final List<RedListChartPointModel> points;

  const _RedListChart({
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(
      1,
      points.fold<int>(
        0,
        (maxValue, item) => math.max(
          maxValue,
          math.max(item.addedCount, item.removedCount),
        ),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            _LegendChip(
              label: _tr(context, 'Добавлено', 'Added'),
              color: AppColors.danger,
            ),
            const SizedBox(width: 8),
            _LegendChip(
              label: _tr(context, 'Удалено', 'Removed'),
              color: AppColors.aqua,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points
                  .map(
                    (point) => Expanded(
                      child: _ChartDayGroup(
                        label: _shortChartLabel(point.dateLabel),
                        addedCount: point.addedCount,
                        removedCount: point.removedCount,
                        maxValue: maxValue,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartDayGroup extends StatelessWidget {
  final String label;
  final int addedCount;
  final int removedCount;
  final int maxValue;

  const _ChartDayGroup({
    required this.label,
    required this.addedCount,
    required this.removedCount,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = 124.0;
    final addedHeight = 18 + ((addedCount / maxValue) * (maxHeight - 18));
    final removedHeight = 18 + ((removedCount / maxValue) * (maxHeight - 18));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _CapsuleMetricBar(
                  value: addedCount,
                  height: addedHeight,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 6),
                _CapsuleMetricBar(
                  value: removedCount,
                  height: removedHeight,
                  color: AppColors.aqua,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.58),
                ),
          ),
        ],
      ),
    );
  }
}

class _CapsuleMetricBar extends StatelessWidget {
  final int value;
  final double height;
  final Color color;

  const _CapsuleMetricBar({
    required this.value,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 14,
          height: 124,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: 14,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.92),
                  color.withValues(alpha: 0.46),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.24),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
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

class _QuestionsSection extends StatelessWidget {
  final List<RedListQuestionModel> questions;
  final Map<int, String> explanations;
  final Map<int, bool> explanationLoading;
  final Future<void> Function(RedListQuestionModel question) onAskAi;

  const _QuestionsSection({
    required this.questions,
    required this.explanations,
    required this.explanationLoading,
    required this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RedSectionTitle(
          title: _tr(context, 'Активные вопросы', 'Active questions'),
          icon: Icons.quiz_rounded,
          color: AppColors.danger,
        ),
        const SizedBox(height: 14),
        if (questions.isEmpty)
          EmptyState(
            title: _tr(context, 'Красный список пуст', 'Red List is empty'),
            subtitle: _tr(
              context,
              'Отличная работа. Сейчас у вас нет активных вопросов в Красном списке.',
              'Great work. You do not have active Red List questions right now.',
            ),
            icon: Icons.check_circle_outline_rounded,
          )
        else
          Column(
            children: questions
                .map(
                  (question) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RedQuestionCard(
                      question: question,
                      explanation: explanations[question.id],
                      isAiLoading: explanationLoading[question.id] == true,
                      onAskAi: () => onAskAi(question),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _RedQuestionCard extends StatefulWidget {
  final RedListQuestionModel question;
  final String? explanation;
  final bool isAiLoading;
  final VoidCallback onAskAi;

  const _RedQuestionCard({
    required this.question,
    required this.explanation,
    required this.isAiLoading,
    required this.onAskAi,
  });

  @override
  State<_RedQuestionCard> createState() => _RedQuestionCardState();
}

class _RedQuestionCardState extends State<_RedQuestionCard> {
  bool _showExplanation = false;

  @override
  void didUpdateWidget(covariant _RedQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.explanation == null &&
        widget.explanation != null &&
        widget.explanation!.trim().isNotEmpty) {
      _showExplanation = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final explanation = widget.explanation;
    final count = widget.question.consecutiveCorrectCount.clamp(0, 3);
    final progress = count / 3;
    final progressColor = switch (count) {
      0 => AppColors.danger,
      1 => AppColors.danger,
      2 => AppColors.gold,
      _ => AppColors.emerald,
    };

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SubjectBadge(
                  label: widget.question.subjectName,
                  icon: _subjectIcon(widget.question.subjectName),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.08),
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$count/3',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: progressColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.tag_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.question.topic,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.48),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _normalizeQuestionText(widget.question.content),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
          ),
          if (_showExplanation && explanation != null && explanation.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _AiExplanationBox(text: explanation),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  _addedAgoLabel(widget.question.addedAt, context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.42),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: _RedActionButton(
                  label: explanation == null
                      ? _tr(context, 'Почему ошибка?', 'Why was it wrong?')
                      : _showExplanation
                          ? _tr(context, 'Скрыть ИИ', 'Hide AI')
                          : _tr(context, 'Помощь ИИ', 'AI help'),
                  icon: widget.isAiLoading
                      ? null
                      : explanation == null
                          ? Icons.auto_awesome_rounded
                          : Icons.lightbulb_outline_rounded,
                  isLoading: widget.isAiLoading,
                  onTap: () {
                    if (explanation != null) {
                      setState(() => _showExplanation = !_showExplanation);
                      return;
                    }
                    widget.onAskAi();
                  },
                ),
              ),
              const SizedBox(width: 8),
              _RoundIconButton(
                icon: Icons.arrow_forward_rounded,
                color: AppColors.aqua,
                onTap: () => context.go(AppRoutes.tests),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiExplanationBox extends StatelessWidget {
  final String text;

  const _AiExplanationBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF111A2A)
            : const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_rounded, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                _tr(context, 'Объяснение ИИ', 'AI explanation'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.80),
                ),
          ),
        ],
      ),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SubjectBadge({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.danger),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RedActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _RedActionButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: AppColors.aqua.withValues(alpha: 0.09),
          side: BorderSide(color: AppColors.aqua.withValues(alpha: 0.16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.aqua,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: AppColors.aqua),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.aqua,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.24),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 18),
      ),
    );
  }
}

class _RedListLockedState extends StatelessWidget {
  final VoidCallback onOpenPremium;

  const _RedListLockedState({
    required this.onOpenPremium,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 34,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _tr(
              context,
              'Красный список доступен только в Premium',
              'Red List is available only in Premium',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _tr(
              context,
              'Откройте умную работу над ошибками, AI-подсказки и персональную практику слабых тем.',
              'Unlock smart mistake review, AI hints, and focused practice for weak topics.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: 'Premium',
            icon: Icons.workspace_premium_rounded,
            onPressed: onOpenPremium,
          ),
        ],
      ),
    );
  }
}

class _RedSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _RedSectionTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

String _tr(BuildContext context, String ru, String en) =>
    Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

String _shortChartLabel(String raw) {
  final parts = raw.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return raw;
  return parts.first;
}

String _normalizeQuestionText(String raw) {
  return raw
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _addedAgoLabel(DateTime? addedAt, BuildContext context) {
  if (addedAt == null) {
    return _tr(context, 'Добавлено недавно', 'Added recently');
  }

  final days = DateTime.now().difference(addedAt.toLocal()).inDays;
  if (days <= 0) return _tr(context, 'Добавлено сегодня', 'Added today');
  if (days == 1) return _tr(context, '1 день назад', '1 day ago');
  return _tr(context, '$days дн. назад', '$days days ago');
}

IconData _subjectIcon(String subject) {
  final lower = subject.toLowerCase();
  if (lower.contains('math') || lower.contains('мат')) {
    return Icons.calculate_rounded;
  }
  if (lower.contains('chem') || lower.contains('хим')) {
    return Icons.science_rounded;
  }
  if (lower.contains('hist') || lower.contains('ист') || lower.contains('таърих')) {
    return Icons.public_rounded;
  }
  if (lower.contains('bio')) {
    return Icons.biotech_rounded;
  }
  if (lower.contains('phys') || lower.contains('физ')) {
    return Icons.bolt_rounded;
  }
  if (lower.contains('code') ||
      lower.contains('c#') ||
      lower.contains('js') ||
      lower.contains('информ')) {
    return Icons.code_rounded;
  }
  return Icons.menu_book_rounded;
}
