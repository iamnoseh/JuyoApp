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
  int? _startingSubjectId;
  List<SubjectTestSubject> _subjects = const [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
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
        _error = _tr(
          context,
          ru: 'Не удалось загрузить список предметов',
          en: 'Unable to load subjects',
        );
      });
    }
  }

  Future<void> _startSubjectTest(SubjectTestSubject subject) async {
    try {
      setState(() => _startingSubjectId = subject.id);
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              ru: 'Не удалось начать тест',
              en: 'Unable to start test',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _startingSubjectId = null);
      }
    }
  }

  List<SubjectTestSubject> get _filteredSubjects {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _subjects;
    return _subjects
        .where((subject) => subject.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopStatsBar(),
      title: context.l10n.testsSubjectMode,
      subtitle: _tr(
        context,
        ru: 'Выберите предмет и начните точечную тренировку',
        en: 'Choose a subject and start focused practice',
      ),
      showHeader: false,
      scrollable: false,
      child: RefreshIndicator(
        color: AppColors.aqua,
        onRefresh: _loadSubjects,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 132),
          children: [
            _SubjectTestsHero(
              totalCount: _subjects.length,
              visibleCount: _filteredSubjects.length,
            ),
            const SizedBox(height: 16),
            _SubjectSearchField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: JuyoPageLoader(),
              )
            else if (_error != null)
              ErrorState(
                title: context.l10n.errorTitle,
                subtitle: _error,
                onRetry: _loadSubjects,
              )
            else if (_subjects.isEmpty)
              EmptyState(
                title: context.l10n.emptyTitle,
                subtitle: _tr(
                  context,
                  ru: 'Предметы пока недоступны. Попробуйте обновить страницу позже.',
                  en: 'No subjects are available yet. Try refreshing again later.',
                ),
                icon: Icons.menu_book_rounded,
              )
            else ...[
              _SubjectsOverviewStrip(subjects: _subjects),
              const SizedBox(height: 16),
              ..._filteredSubjects.map(
                (subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SubjectTestCard(
                    subject: subject,
                    isStarting: _startingSubjectId == subject.id,
                    onTap: () => _startSubjectTest(subject),
                  ),
                ),
              ),
              if (_filteredSubjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: EmptyState(
                    title: _tr(
                      context,
                      ru: 'Ничего не найдено',
                      en: 'Nothing found',
                    ),
                    subtitle: _tr(
                      context,
                      ru: 'Попробуйте изменить запрос поиска.',
                      en: 'Try changing the search query.',
                    ),
                    icon: Icons.search_off_rounded,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubjectTestsHero extends StatelessWidget {
  final int totalCount;
  final int visibleCount;

  const _SubjectTestsHero({
    required this.totalCount,
    required this.visibleCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.aqua.withValues(alpha: 0.20),
                      AppColors.gold.withValues(alpha: 0.18),
                    ],
                  ),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.aqua,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        context,
                        ru: 'Тесты по предметам',
                        en: 'Subject tests',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: primaryText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tr(
                        context,
                        ru: 'Точечная тренировка по одной дисциплине без лишних шагов.',
                        en: 'Focused practice for one discipline without extra steps.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatPill(
                color: AppColors.aqua,
                icon: Icons.library_books_rounded,
                label: _tr(
                  context,
                  ru: 'Всего предметов',
                  en: 'Total subjects',
                ),
                value: '$totalCount',
              ),
              _HeroStatPill(
                color: AppColors.gold,
                icon: Icons.filter_alt_rounded,
                label: _tr(
                  context,
                  ru: 'В списке',
                  en: 'Visible now',
                ),
                value: '$visibleCount',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;

  const _HeroStatPill({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$value ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                ),
                TextSpan(
                  text: label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
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

class _SubjectSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SubjectSearchField({
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
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 20,
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
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: _tr(
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

class _SubjectsOverviewStrip extends StatelessWidget {
  final List<SubjectTestSubject> subjects;

  const _SubjectsOverviewStrip({
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    final preview = subjects.take(6).toList();

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: preview.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final subject = preview[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.aqua.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.aqua.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _subjectFallbackIcon(subject.name),
                  size: 14,
                  color: AppColors.aqua,
                ),
                const SizedBox(width: 8),
                Text(
                  subject.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubjectTestCard extends StatelessWidget {
  final SubjectTestSubject subject;
  final bool isStarting;
  final VoidCallback onTap;

  const _SubjectTestCard({
    required this.subject,
    required this.isStarting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryText =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return GlassCard(
      onTap: isStarting ? null : onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _SubjectIconTile(subject: subject),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  _tr(
                    context,
                    ru: 'Запустить быстрый тест по этому предмету',
                    en: 'Start a focused test for this subject',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryText,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _TinyMetaChip(
                      icon: Icons.timer_outlined,
                      label: _tr(
                        context,
                        ru: 'Мгновенный старт',
                        en: 'Instant start',
                      ),
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    _TinyMetaChip(
                      icon: Icons.track_changes_rounded,
                      label: _tr(
                        context,
                        ru: 'Один предмет',
                        en: 'One subject',
                      ),
                      color: AppColors.aqua,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isStarting
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: AppColors.aqua,
                    ),
                  )
                : Container(
                    key: const ValueKey('action'),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.gold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TinyMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TinyMetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
          ),
        ],
      ),
    );
  }
}

class _SubjectIconTile extends StatelessWidget {
  final SubjectTestSubject subject;

  const _SubjectIconTile({
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveAssetUrl(subject.imagePath);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 56,
      height: 56,
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
      padding: const EdgeInsets.all(7),
      child: imageUrl == null
          ? Center(
              child: Icon(
                _subjectFallbackIcon(subject.name),
                color: AppColors.aqua,
                size: 22,
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
                    size: 22,
                  ),
                ),
              ),
            ),
    );
  }
}

String _tr(
  BuildContext context, {
  required String ru,
  required String en,
}) {
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

  return _tr(context, ru: ruFallback, en: enFallback);
}

String? _resolveAssetUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;

  var cleanPath = rawUrl.replaceAll('\\', '/').trim();
  cleanPath = cleanPath.replaceFirst(RegExp(r'^/?wwwroot/', caseSensitive: false), '');
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
