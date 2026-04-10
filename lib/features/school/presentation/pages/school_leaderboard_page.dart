import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class SchoolLeaderboardPage extends StatefulWidget {
  const SchoolLeaderboardPage({super.key});

  @override
  State<SchoolLeaderboardPage> createState() => _SchoolLeaderboardPageState();
}

class _SchoolLeaderboardPageState extends State<SchoolLeaderboardPage> {
  bool _loading = true;
  String? _error;
  List<_SchoolStanding> _schools = const [];
  _SchoolStanding? _userSchool;
  int? _expandedSchoolId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final response = await ApiClient.dio.get('/Schools/leaderboard');
      final body = response.data;
      final data = body is Map ? (body['data'] ?? body) : body;

      final rawLeaderboard = data is Map
          ? (data['leaderboard'] ?? data['Leaderboard'] ?? data['schools'])
          : data;
      final rawUserSchool = data is Map
          ? (data['userSchool'] ?? data['UserSchool'])
          : null;
      final userSchool = rawUserSchool is Map
          ? _SchoolStanding.fromMap(Map<dynamic, dynamic>.from(rawUserSchool))
          : null;
      final userSchoolId = userSchool?.schoolId;
      final schools = (rawLeaderboard as List<dynamic>? ?? const [])
          .whereType<Map>()
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => _SchoolStanding.fromMap(
              Map<dynamic, dynamic>.from(entry.value),
              fallbackRank: entry.key + 1,
              userSchoolId: userSchoolId,
            ),
          )
          .toList();

      setState(() {
        _schools = schools;
        _userSchool = userSchool;
        _loading = false;
      });
    } on DioException catch (error) {
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      topBar: const AppTopStatsBar(),
      title: l10n.schoolTitle,
      subtitle: l10n.schoolSubtitle,
      child: _loading
          ? const SizedBox(height: 420, child: JuyoPageLoader())
          : _error != null
              ? ErrorState(
                  title: l10n.errorTitle,
                  subtitle: _error,
                  onRetry: () => _loadData(),
                )
              : _schools.isEmpty
                  ? EmptyState(
                      title: l10n.emptyTitle,
                      subtitle: l10n.emptySubtitle,
                      icon: Icons.school_outlined,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SchoolHeroCard(
                          totalSchools: _schools.length,
                          userSchool: _userSchool,
                        ),
                        const SizedBox(height: 14),
                        ..._schools.map(
                          (school) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SchoolStandingCard(
                              school: school,
                              isExpanded:
                                  _expandedSchoolId == school.schoolId,
                              onTap: () {
                                setState(() {
                                  _expandedSchoolId =
                                      _expandedSchoolId == school.schoolId
                                          ? null
                                          : school.schoolId;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _SchoolHeroCard extends StatelessWidget {
  final int totalSchools;
  final _SchoolStanding? userSchool;

  const _SchoolHeroCard({
    required this.totalSchools,
    required this.userSchool,
  });

  @override
  Widget build(BuildContext context) {
    final school = userSchool;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.aqua.withValues(alpha: 0.26),
                  AppColors.gold.withValues(alpha: 0.16),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.aqua.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(Icons.apartment_rounded, color: AppColors.aqua),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr(context, 'Рейтинг школ', 'School ranking'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  school == null
                      ? _tr(
                          context,
                          '$totalSchools школ в рейтинге',
                          '$totalSchools schools ranked',
                        )
                      : _tr(
                          context,
                          'Ваша школа: #${school.rank}',
                          'Your school: #${school.rank}',
                        ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: isDark ? 0.74 : 0.68),
                      ),
                ),
              ],
            ),
          ),
          if (school != null)
            _MiniMetric(
              label: 'AVG',
              value: school.averageXp.toStringAsFixed(1),
              color: AppColors.aqua,
            ),
        ],
      ),
    );
  }
}

class _SchoolStandingCard extends StatelessWidget {
  final _SchoolStanding school;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SchoolStandingCard({
    required this.school,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final region = [
      school.province,
      school.district,
    ].where((value) => value.trim().isNotEmpty).join(' • ');

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              _SchoolRankBadge(rank: school.rank),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.schoolName,
                      maxLines: isExpanded ? 3 : 1,
                      overflow: isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    if (school.isMe) ...[
                      const SizedBox(height: 6),
                      _InlineSchoolMetric(
                        label: _tr(context, 'моя', 'mine'),
                        value: 'JUYO',
                        color: AppColors.gold,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (region.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: isDark ? 0.68 : 0.58),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            region,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(
                                            alpha: isDark ? 0.74 : 0.68,
                                          ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _MiniMetric(
                          label: _tr(context, 'Средний балл', 'Average'),
                          value: school.averageXp.toStringAsFixed(1),
                          color: AppColors.aqua,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniMetric(
                          label: _tr(context, 'Всего балл', 'Total score'),
                          value: _formatNumber(school.totalXp),
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniMetric(
                          label: _tr(context, 'Всего учеников', 'Students'),
                          value: '${school.studentCount}',
                          color: AppColors.emerald,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchoolRankBadge extends StatelessWidget {
  final int rank;

  const _SchoolRankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final icon = switch (rank) {
      1 => Icons.workspace_premium_rounded,
      2 => Icons.military_tech_rounded,
      3 => Icons.verified_rounded,
      _ => Icons.tag_rounded,
    };
    final color = switch (rank) {
      1 => AppColors.gold,
      2 => const Color(0xFFC0CAD7),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.aqua,
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: isTopThree
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.24),
                  color.withValues(alpha: 0.08),
                ],
              )
            : null,
        color: isTopThree ? null : AppColors.aqua.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isTopThree ? 16 : 13, color: color),
          const SizedBox(height: 1),
          Text(
            '#$rank',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.68),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _InlineSchoolMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InlineSchoolMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
          ),
        ],
      ),
    );
  }
}
class _SchoolStanding {
  final int rank;
  final int schoolId;
  final String schoolName;
  final String province;
  final String district;
  final int totalXp;
  final int studentCount;
  final double averageXp;
  final bool isMe;

  const _SchoolStanding({
    required this.rank,
    required this.schoolId,
    required this.schoolName,
    required this.province,
    required this.district,
    required this.totalXp,
    required this.studentCount,
    required this.averageXp,
    required this.isMe,
  });

  factory _SchoolStanding.fromMap(
    Map<dynamic, dynamic> json, {
    int? fallbackRank,
    int? userSchoolId,
  }) {
    final schoolId = _asInt(json['schoolId'] ?? json['SchoolId'] ?? json['id']);
    return _SchoolStanding(
      rank: _asInt(json['rank'] ?? json['Rank'], fallback: fallbackRank ?? 0),
      schoolId: schoolId,
      schoolName:
          (json['schoolName'] ?? json['SchoolName'] ?? json['name'] ?? '-')
              .toString(),
      province: (json['province'] ?? json['Province'] ?? '').toString(),
      district: (json['district'] ?? json['District'] ?? '').toString(),
      totalXp: _asInt(json['totalXP'] ?? json['TotalXP'] ?? json['totalXp']),
      studentCount:
          _asInt(json['studentCount'] ?? json['StudentCount'] ?? json['students']),
      averageXp:
          _asDouble(json['averageXP'] ?? json['AverageXP'] ?? json['averageXp']),
      isMe: userSchoolId != null && userSchoolId == schoolId,
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final remaining = text.length - i;
    buffer.write(text[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(' ');
    }
  }
  return buffer.toString();
}

String _tr(BuildContext context, String ru, String en) {
  return Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
}
