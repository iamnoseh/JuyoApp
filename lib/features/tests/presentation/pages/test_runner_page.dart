import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/constants/app_constants.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/core/widgets/aurora_background.dart';
import 'package:juyo/features/tests/data/models/test_session_models.dart';
import 'package:juyo/features/tests/data/repositories/test_session_repository.dart';

class TestRunnerPage extends StatefulWidget {
  final String sessionId;

  const TestRunnerPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<TestRunnerPage> createState() => _TestRunnerPageState();
}

class _TestRunnerPageState extends State<TestRunnerPage> {
  final TestSessionRepository _repository = const TestSessionRepository();
  final TextEditingController _textController = TextEditingController();

  List<TestQuestionModel> _questions = const [];
  Map<int, bool> _answered = <int, bool>{};
  Map<int, String> _pairs = <int, String>{};
  SubmitAnswerFeedbackModel? _feedback;
  String? _error;
  String _textAnswer = '';
  int _index = 0;
  int? _selectedAnswerId;
  int _remainingSeconds = 20 * 60;
  bool _loading = true;
  bool _submitting = false;
  bool _finishing = false;
  bool _requestAi = false;
  Timer? _timer;

  TestQuestionModel? get _question =>
      _questions.isEmpty ? null : _questions[_index];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final questions = await _repository.getQuestions(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _loading = false;
        _error = questions.isEmpty ? 'No questions found' : null;
      });
      if (questions.isNotEmpty) {
        _startTimer();
        _resetLocalState();
      }
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _extractError(
          error,
          fallback: _t(
            context,
            ru: 'Не удалось загрузить вопросы',
            en: 'Unable to load questions',
          ),
        );
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted || _finishing) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        await _finish();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _resetLocalState() {
    _feedback = null;
    _selectedAnswerId = null;
    _pairs = <int, String>{};
    _textAnswer = '';
    _textController.clear();
  }

  Future<void> _submit() async {
    final question = _question;
    if (question == null || _submitting || _feedback != null) return;

    int? chosenAnswerId;
    String? textResponse;

    if (question.type == TestQuestionType.singleChoice) {
      if (_selectedAnswerId == null) {
        return _snack(_t(context, ru: 'Выберите ответ', en: 'Select an answer'));
      }
      chosenAnswerId = _selectedAnswerId;
    } else if (question.type == TestQuestionType.matching) {
      if (_pairs.length < question.answers.length) {
        return _snack(_t(context, ru: 'Сопоставьте все пары', en: 'Match all pairs'));
      }
      textResponse = question.answers
          .map((answer) => '${answer.id}:${_pairs[answer.id] ?? ''}')
          .where((pair) => !pair.endsWith(':'))
          .join(',');
    } else {
      final value = _textAnswer.trim();
      if (value.isEmpty) {
        return _snack(_t(context, ru: 'Введите ответ', en: 'Enter your answer'));
      }
      textResponse = value;
    }

    try {
      setState(() => _submitting = true);
      final feedback = await _repository.submitAnswer(
        sessionId: widget.sessionId,
        questionId: question.id,
        chosenAnswerId: chosenAnswerId,
        textResponse: textResponse,
        requestAiFeedback: _requestAi,
      );
      if (!mounted) return;
      setState(() {
        _feedback = feedback;
        _answered = Map<int, bool>.from(_answered)..[question.id] = true;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      _snack(
        _extractError(
          error,
          fallback: _t(
            context,
            ru: 'Не удалось отправить ответ',
            en: 'Unable to submit answer',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    try {
      setState(() => _finishing = true);
      _timer?.cancel();
      final result = await _repository.finishTest(widget.sessionId);
      if (!mounted) return;
      context.go(
        '${AppRoutes.testResult}/${widget.sessionId}',
        extra: {
          'result': result,
          'elapsedSeconds': (20 * 60) - _remainingSeconds,
        },
      );
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() => _finishing = false);
      _snack(
        _extractError(
          error,
          fallback: _t(
            context,
            ru: 'Не удалось завершить тест',
            en: 'Unable to finish the test',
          ),
        ),
      );
    }
  }

  void _goNext() {
    if (_index >= _questions.length - 1) {
      _finish();
      return;
    }
    setState(() => _index += 1);
    _resetLocalState();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: _loading
              ? const JuyoPageLoader()
              : _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: ErrorState(
                        title: _t(context, ru: 'Ошибка', en: 'Error'),
                        subtitle: _error,
                        onRetry: _load,
                      ),
                    )
                  : _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final question = _question;
    if (question == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: EmptyState(
          title: _t(context, ru: 'Пусто', en: 'Empty'),
          subtitle: _t(
            context,
            ru: 'В этой сессии нет вопросов.',
            en: 'This test session has no questions.',
          ),
          icon: Icons.quiz_outlined,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.subjectName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        _t(
                          context,
                          ru: 'Вопрос ${_index + 1} из ${_questions.length}',
                          en: 'Question ${_index + 1} of ${_questions.length}',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatChip(
                  label: _formatTime(_remainingSeconds),
                  icon: Icons.timer_outlined,
                  color: _remainingSeconds < 300 ? AppColors.danger : AppColors.gold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _questions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isCurrent = index == _index;
                      final isAnswered = _answered[_questions[index].id] == true;
                      final color = isCurrent
                          ? AppColors.gold
                          : isAnswered
                              ? AppColors.aqua
                              : AppColors.textMuted;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _index = index);
                          _resetLocalState();
                        },
                        child: Container(
                          width: 42,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: color.withValues(alpha: 0.18)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _metaBadge(question.subjectName, AppColors.aqua),
                          if ((question.topic ?? '').trim().isNotEmpty)
                            _metaBadge(question.topic!, AppColors.gold),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question.content,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if ((question.imageUrl ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            _resolveUrl(question.imageUrl)!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(child: _buildAnswerPanel(question)),
                if (_feedback != null) ...[
                  const SizedBox(height: 14),
                  GlassCard(child: _buildFeedbackPanel(question)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Switch.adaptive(
                        value: _requestAi,
                        onChanged: _feedback == null
                            ? (value) => setState(() => _requestAi = value)
                            : null,
                        activeThumbColor: AppColors.aqua,
                        activeTrackColor: AppColors.aqua.withValues(alpha: 0.34),
                      ),
                      Expanded(
                        child: Text(
                          _t(context, ru: 'AI-пояснение', en: 'AI feedback'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 152,
                  child: _feedback == null
                      ? AppPrimaryButton(
                          label: _t(context, ru: 'Ответить', en: 'Submit'),
                          onPressed: _submit,
                          isLoading: _submitting,
                        )
                      : AppPrimaryButton(
                          label: _index == _questions.length - 1
                              ? _t(context, ru: 'Завершить', en: 'Finish')
                              : _t(context, ru: 'Далее', en: 'Next'),
                          onPressed: _goNext,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerPanel(TestQuestionModel question) {
    if (question.type == TestQuestionType.singleChoice) {
      return Column(
        children: question.answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          final state = _singleChoiceState(
            answer: answer,
            selectedAnswerId: _selectedAnswerId,
            feedback: _feedback,
          );

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == question.answers.length - 1 ? 0 : 10,
            ),
            child: GestureDetector(
              onTap: _feedback == null
                  ? () => setState(() => _selectedAnswerId = answer.id)
                  : null,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _stateColor(state).withValues(
                    alpha: state == _OptionState.normal ? 0.03 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _stateColor(state).withValues(
                      alpha: state == _OptionState.normal ? 0.12 : 0.26,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _stateColor(state).withValues(
                          alpha: state == _OptionState.normal ? 0.12 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: state == _OptionState.normal
                                  ? AppColors.aqua
                                  : Colors.white,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        answer.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: state == _OptionState.correct
                                  ? AppColors.emerald
                                  : state == _OptionState.incorrect
                                      ? AppColors.danger
                                      : null,
                            ),
                      ),
                    ),
                    if (state == _OptionState.correct)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.emerald,
                      ),
                    if (state == _OptionState.incorrect)
                      const Icon(
                        Icons.cancel_rounded,
                        color: AppColors.danger,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    if (question.type == TestQuestionType.matching) {
      return Column(
        children: question.answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          final validation = _matchingValidation(answer.text, _feedback);
          final rowColor = validation == null
              ? Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF0F172A)
              : validation.isCorrect
                  ? AppColors.emerald
                  : AppColors.danger;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == question.answers.length - 1 ? 0 : 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: rowColor.withValues(alpha: validation == null ? 0.03 : 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: rowColor.withValues(alpha: validation == null ? 0.10 : 0.20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    answer.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _pairs[answer.id],
                    isExpanded: true,
                    items: question.matchOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) {
                      return question.matchOptions
                          .map(
                            (option) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList();
                    },
                    onChanged: _feedback != null
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _pairs = Map<int, String>.from(_pairs)
                                  ..[answer.id] = value;
                              });
                            }
                          },
                    decoration: InputDecoration(
                      hintText: _t(
                        context,
                        ru: 'Выберите пару',
                        en: 'Select a pair',
                      ),
                    ),
                  ),
                  if (validation != null && !validation.isCorrect) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_t(context, ru: 'Правильно', en: 'Correct')}: ${validation.correctRightSide}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    final borderColor = _feedback == null
        ? Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0)
        : _feedback!.isCorrect
            ? AppColors.emerald.withValues(alpha: 0.24)
            : AppColors.danger.withValues(alpha: 0.24);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: _textController,
        onChanged: (value) => _textAnswer = value,
        enabled: _feedback == null,
        minLines: 2,
        maxLines: 3,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          hintText: _t(
            context,
            ru: 'Введите ваш ответ...',
            en: 'Enter your answer...',
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackPanel(TestQuestionModel question) {
    final feedback = _feedback!;
    final partial = !feedback.isCorrect &&
        ((feedback.score ?? 0) > 0 || (feedback.correctPairsCount ?? 0) > 0);
    final color = feedback.isCorrect
        ? AppColors.emerald
        : partial
            ? AppColors.gold
            : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              feedback.isCorrect
                  ? Icons.check_circle_rounded
                  : partial
                      ? Icons.info_rounded
                      : Icons.cancel_rounded,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                feedback.isCorrect
                    ? _t(context, ru: 'Верно', en: 'Correct')
                    : partial
                        ? _t(context, ru: 'Частично верно', en: 'Partially correct')
                        : _t(context, ru: 'Неверно', en: 'Incorrect'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ],
        ),
        if ((feedback.feedbackText ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            feedback.feedbackText!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (question.type != TestQuestionType.matching &&
            !feedback.isCorrect &&
            (feedback.correctAnswerText ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${_t(context, ru: 'Правильный ответ', en: 'Correct answer')}: ${feedback.correctAnswerText}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.emerald,
                ),
          ),
        ],
      ],
    );
  }

  Widget _metaBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
      ),
    );
  }
}

enum _OptionState { normal, selected, correct, incorrect }

_OptionState _singleChoiceState({
  required TestAnswerOption answer,
  required int? selectedAnswerId,
  required SubmitAnswerFeedbackModel? feedback,
}) {
  if (feedback == null) {
    return selectedAnswerId == answer.id
        ? _OptionState.selected
        : _OptionState.normal;
  }

  final normalizedCorrect = _normalize(feedback.correctAnswerText);
  final normalizedAnswer = _normalize(answer.text);

  if (normalizedCorrect.isNotEmpty && normalizedCorrect == normalizedAnswer) {
    return _OptionState.correct;
  }

  if (selectedAnswerId == answer.id && !feedback.isCorrect) {
    return _OptionState.incorrect;
  }

  if (selectedAnswerId == answer.id && feedback.isCorrect) {
    return _OptionState.correct;
  }

  return _OptionState.normal;
}

ValidationPairModel? _matchingValidation(
  String leftSide,
  SubmitAnswerFeedbackModel? feedback,
) {
  if (feedback == null) return null;
  for (final pair in feedback.validationPairs) {
    if (_normalize(pair.leftSide) == _normalize(leftSide)) {
      return pair;
    }
  }
  return null;
}

Color _stateColor(_OptionState state) {
  switch (state) {
    case _OptionState.selected:
      return AppColors.aqua;
    case _OptionState.correct:
      return AppColors.emerald;
    case _OptionState.incorrect:
      return AppColors.danger;
    case _OptionState.normal:
      return AppColors.textMuted;
  }
}

String _normalize(String? value) {
  return (value ?? '').trim().toLowerCase();
}

String _t(BuildContext context, {required String ru, required String en}) {
  return Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
}

String _extractError(DioException error, {required String fallback}) {
  final data = error.response?.data;
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    for (final key in const ['message', 'Message', 'error', 'Error']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }
  final message = error.message;
  return message != null && message.trim().isNotEmpty ? message.trim() : fallback;
}

String _formatTime(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}

String? _resolveUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;
  var cleanPath = rawUrl.replaceAll('\\', '/').trim();
  cleanPath = cleanPath.replaceFirst(
    RegExp(r'^/?wwwroot/', caseSensitive: false),
    '',
  );
  cleanPath = cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath;
  if (cleanPath.startsWith('uploads/') || cleanPath.startsWith('questions/')) {
    final encoded = cleanPath.split('/').map(Uri.encodeComponent).join('/');
    return 'https://storage.googleapis.com/iqra-tj/$encoded';
  }
  final host = AppConstants.apiBaseUrl.replaceFirst('/api', '');
  return rawUrl.startsWith('/') ? '$host$rawUrl' : '$host/$rawUrl';
}
