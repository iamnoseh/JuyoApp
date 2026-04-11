import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/constants/app_constants.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/tests/data/models/subject_test_subject.dart';
import 'package:juyo/features/tests/data/repositories/subject_tests_repository.dart';

class SubjectTestsPage extends StatefulWidget {
  const SubjectTestsPage({super.key});

  @override
  State<SubjectTestsPage> createState() => _SubjectTestsPageState();
}

class _SubjectTestsPageState extends State<SubjectTestsPage> {
  final SubjectTestsRepository _repository = const SubjectTestsRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  String _query = '';
  int? _startingId;
  List<SubjectTestSubject> _subjects = const [];

  List<SubjectTestSubject> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _subjects;
    return _subjects
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final subjects = await _repository.getSubjects();
      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _loading = false;
        _error = null;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _extractErrorMessage(
          error,
          context,
          ruFallback: 'Не удалось загрузить список предметов',
          enFallback: 'Unable to load subjects',
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _t(
          context,
          ru: 'Не удалось загрузить список предметов',
          en: 'Unable to load subjects',
        );
      });
    }
  }

  Future<void> _start(SubjectTestSubject subject) async {
    try {
      setState(() => _startingId = subject.id);
      final sessionId = await _repository.startSubjectTest(subject.id);
      if (!mounted) return;
      context.push('${AppRoutes.testRunner}/$sessionId');
    } on DioException catch (error) {
      if (!mounted) return;
      final message = isSubjectTestForbidden(error)
          ? context.l10n.lockedTitle
          : _extractErrorMessage(
              error,
              context,
              ruFallback: 'Не удалось начать тест',
              enFallback: 'Unable to start test',
            );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _startingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopStatsBar(),
      title: context.l10n.testsSubjectMode,
      subtitle: _t(
        context,
        ru: 'Выберите предмет и начните быструю тренировку',
        en: 'Choose a subject and start a focused drill',
      ),
      showHeader: false,
      scrollable: false,
      child: RefreshIndicator(
        color: AppColors.aqua,
        onRefresh: _load,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 128),
          children: [
            const _SubjectHero(),
            const SizedBox(height: 16),
            _SubjectSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: JuyoPageLoader(),
              )
            else if (_error != null)
              ErrorState(
                title: context.l10n.errorTitle,
                subtitle: _error,
                onRetry: _load,
              )
            else if (_subjects.isEmpty)
              EmptyState(
                title: context.l10n.emptyTitle,
                subtitle: _t(
                  context,
                  ru: 'Предметы пока недоступны.',
                  en: 'Subjects are not available yet.',
                ),
                icon: Icons.menu_book_rounded,
              )
            else ...[
              ..._filtered.map(
                (subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SubjectCard(
                    subject: subject,
                    starting: _startingId == subject.id,
                    onTap: () => _start(subject),
                  ),
                ),
              ),
              if (_filtered.isEmpty)
                EmptyState(
                  title: _t(
                    context,
                    ru: 'Ничего не найдено',
                    en: 'Nothing found',
                  ),
                  subtitle: _t(
                    context,
                    ru: 'Попробуйте изменить запрос.',
                    en: 'Try changing the search query.',
                  ),
                  icon: Icons.search_off_rounded,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubjectHero extends StatelessWidget {
  const _SubjectHero();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  AppColors.aqua.withValues(alpha: 0.18),
                  AppColors.gold.withValues(alpha: 0.14),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.aqua,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(context, ru: 'Тесты по предметам', en: 'Subject tests'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  _t(
                    context,
                    ru: 'Один предмет, быстрый старт, чистый фокус.',
                    en: 'One subject, quick start, clean focus.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SubjectSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: isDark ? 0.20 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.aqua),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: _t(
                  context,
                  ru: 'Поиск предмета...',
                  en: 'Search subject...',
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectTestSubject subject;
  final bool starting;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.starting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: starting ? null : onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubjectIcon(subject: subject),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _t(
                    context,
                    ru: 'Быстрый тест по одному предмету с мгновенным запуском.',
                    en: 'Quick one-subject test with instant start.',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          starting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: AppColors.aqua,
                  ),
                )
              : Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.gold,
                  ),
                ),
        ],
      ),
    );
  }
}

class _SubjectIcon extends StatelessWidget {
  final SubjectTestSubject subject;

  const _SubjectIcon({
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveAssetUrl(subject.imagePath);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.aqua.withValues(alpha: 0.18),
            AppColors.gold.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: imageUrl == null
          ? Center(
              child: Icon(
                _subjectFallbackIcon(subject.name),
                color: AppColors.aqua,
                size: 24,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    _subjectFallbackIcon(subject.name),
                    color: AppColors.aqua,
                    size: 24,
                  ),
                ),
              ),
            ),
    );
  }
}

String _t(BuildContext context, {required String ru, required String en}) {
  return Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
}

String _extractErrorMessage(
  DioException error,
  BuildContext context, {
  required String ruFallback,
  required String enFallback,
}) {
  final data = error.response?.data;
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    for (final key in const ['message', 'Message', 'error', 'Error']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
  }

  final message = error.message;
  if (message != null && message.trim().isNotEmpty) {
    return message.trim();
  }

  return _t(context, ru: ruFallback, en: enFallback);
}

String? _resolveAssetUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
    return rawUrl;
  }

  var cleanPath = rawUrl.replaceAll('\\', '/').trim();
  cleanPath = cleanPath.replaceFirst(
    RegExp(r'^/?wwwroot/', caseSensitive: false),
    '',
  );
  cleanPath = cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath;

  if (cleanPath.startsWith('qrcodes/') ||
      cleanPath.startsWith('receipts/') ||
      cleanPath.startsWith('uploads/') ||
      cleanPath.startsWith('subjects/')) {
    final encoded = cleanPath.split('/').map(Uri.encodeComponent).join('/');
    return 'https://storage.googleapis.com/iqra-tj/$encoded';
  }

  final host = AppConstants.apiBaseUrl.replaceFirst('/api', '');
  return rawUrl.startsWith('/') ? '$host$rawUrl' : '$host/$rawUrl';
}

IconData _subjectFallbackIcon(String name) {
  final value = name.toLowerCase();

  if (value.contains('мат') || value.contains('algebra')) {
    return Icons.calculate_rounded;
  }
  if (value.contains('физ') || value.contains('physics')) {
    return Icons.bolt_rounded;
  }
  if (value.contains('хим') || value.contains('chem')) {
    return Icons.science_rounded;
  }
  if (value.contains('био') || value.contains('bio')) {
    return Icons.eco_rounded;
  }
  if (value.contains('гео') || value.contains('geo')) {
    return Icons.public_rounded;
  }
  if (value.contains('истор') || value.contains('history')) {
    return Icons.history_edu_rounded;
  }
  if (value.contains('англ') || value.contains('english')) {
    return Icons.translate_rounded;
  }
  if (value.contains('литер') || value.contains('язык') || value.contains('lang')) {
    return Icons.menu_book_rounded;
  }
  if (value.contains('информ') || value.contains('computer')) {
    return Icons.memory_rounded;
  }

  return Icons.school_rounded;
}
