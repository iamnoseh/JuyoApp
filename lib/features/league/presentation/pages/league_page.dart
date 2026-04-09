import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:juyo/core/constants/app_constants.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class LeagueStudentPage extends StatefulWidget {
  const LeagueStudentPage({super.key});

  @override
  State<LeagueStudentPage> createState() => _LeagueStudentPageState();
}

class _LeagueStudentPageState extends State<LeagueStudentPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _leagues = const [];
  List<Map<String, dynamic>> _standings = const [];
  int? _selectedLeagueId;
  String? _expandedStandingKey;

  @override
  void initState() {
    super.initState();
    _loadLeagues();
  }

  Future<void> _loadLeagues() async {
    try {
      final response = await ApiClient.dio.get('/League');
      final raw = response.data is Map
          ? response.data['data'] ?? response.data
          : response.data;
      final leagues = (raw as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      setState(() {
        _leagues = leagues;
        _selectedLeagueId =
            leagues.isEmpty ? null : (leagues.first['id'] as num?)?.toInt();
      });
      if (_selectedLeagueId != null) {
        await _loadStandings(_selectedLeagueId!);
      } else {
        setState(() => _loading = false);
      }
    } on DioException catch (error) {
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _loadStandings(int leagueId) async {
    try {
      setState(() => _loading = true);
      final response = await ApiClient.dio.get('/League/$leagueId/standings');
      final raw = response.data is Map
          ? response.data['data'] ?? response.data
          : response.data;
      final standings = (raw as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      setState(() {
        _standings = standings;
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
      title: l10n.leagueTitle,
      subtitle: l10n.leagueSubtitle,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(title: l10n.errorTitle, subtitle: _error)
              : Column(
                  children: [
                    if (_leagues.isNotEmpty)
                      SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final league = _leagues[index];
                            final id = (league['id'] as num?)?.toInt();
                            final selected = id == _selectedLeagueId;
                            return ChoiceChip(
                              label:
                                  Text(league['name']?.toString() ?? 'League'),
                              selected: selected,
                              onSelected: (_) {
                                if (id == null) return;
                                setState(() => _selectedLeagueId = id);
                                _loadStandings(id);
                              },
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemCount: _leagues.length,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_standings.isEmpty)
                      EmptyState(
                        title: l10n.emptyTitle,
                        subtitle: l10n.emptySubtitle,
                        icon: Icons.emoji_events_outlined,
                      )
                    else
                      ..._standings.take(10).map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _StandingCard(
                                item: item,
                                isExpanded:
                                    _expandedStandingKey == _standingKey(item),
                                onToggle: () {
                                  final key = _standingKey(item);
                                  setState(() {
                                    _expandedStandingKey =
                                        _expandedStandingKey == key
                                            ? null
                                            : key;
                                  });
                                },
                              ),
                            ),
                          ),
                  ],
                ),
    );
  }

  String _standingKey(Map<String, dynamic> item) {
    return item['userId']?.toString() ??
        item['id']?.toString() ??
        item['rank']?.toString() ??
        item['userFullName']?.toString() ??
        item['name']?.toString() ??
        '';
  }
}

class _StandingCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _StandingCard({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final rank = item['rank']?.toString() ?? '-';
    final fullName =
        item['userFullName']?.toString() ?? item['name']?.toString() ?? 'User';
    final schoolName = item['schoolName']?.toString();
    final weeklyXp = item['weeklyXP'] ?? item['xp'] ?? 0;
    final isPremium = _asBool(
      item['isPremium'] ?? item['premium'] ?? item['hasPremium'],
    );
    final trend = _resolveTrend(item['trend']?.toString());
    final avatarUrl = _resolveAvatarUrl(
      item['avatarUrl']?.toString() ??
          item['profilePictureUrl']?.toString() ??
          item['profilePicture']?.toString(),
    );

    return GlassCard(
      onTap: onToggle,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              _RankBadge(rank: rank),
              const SizedBox(width: 12),
              _LeagueAvatar(
                fullName: fullName,
                avatarUrl: avatarUrl,
                isPremium: isPremium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$weeklyXp XP',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(width: 6),
                        _TrendBadge(trend: trend),
                      ],
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 180),
                      crossFadeState: isExpanded &&
                              schoolName != null &&
                              schoolName.trim().isNotEmpty
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox(height: 0),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          schoolName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  _StandingTrend _resolveTrend(String? raw) {
    final value = raw?.trim().toUpperCase();
    if (value == 'UP') return _StandingTrend.up;
    if (value == 'DOWN') return _StandingTrend.down;
    return _StandingTrend.stable;
  }

  String? _resolveAvatarUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    final host = AppConstants.apiBaseUrl.replaceFirst('/api', '');
    if (rawUrl.startsWith('/')) {
      return '$host$rawUrl';
    }
    return '$host/$rawUrl';
  }
}

class _RankBadge extends StatelessWidget {
  final String rank;

  const _RankBadge({
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final rankNumber = int.tryParse(rank);
    final isTopThree = rankNumber != null && rankNumber <= 3;
    final medalIcon = switch (rankNumber) {
      1 => Icons.workspace_premium_rounded,
      2 => Icons.military_tech_rounded,
      3 => Icons.verified_rounded,
      _ => null,
    };
    final medalColor = switch (rankNumber) {
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
                  medalColor.withValues(alpha: 0.24),
                  medalColor.withValues(alpha: 0.08),
                ],
              )
            : null,
        color: isTopThree ? null : AppColors.aqua.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: medalColor.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: isTopThree
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(medalIcon, size: 16, color: medalColor),
                const SizedBox(height: 2),
                Text(
                  '#$rank',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: medalColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            )
          : Center(
              child: Text(
                '#$rank',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.aqua,
                    ),
              ),
            ),
    );
  }
}

class _LeagueAvatar extends StatelessWidget {
  final String fullName;
  final String? avatarUrl;
  final bool isPremium;

  const _LeagueAvatar({
    required this.fullName,
    required this.avatarUrl,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final initials = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: isPremium
                ? const LinearGradient(
                    colors: [Color(0xFFFFD166), AppColors.gold],
                  )
                : LinearGradient(
                    colors: [
                      AppColors.aqua.withValues(alpha: 0.22),
                      AppColors.aqua.withValues(alpha: 0.08),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPremium
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _AvatarFallback(initials: initials),
                  )
                : _AvatarFallback(initials: initials),
          ),
        ),
        if (isPremium)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'PRO',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 7,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initials;

  const _AvatarFallback({
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF132033)
          : Colors.white,
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'U' : initials,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

enum _StandingTrend { up, down, stable }

class _TrendBadge extends StatelessWidget {
  final _StandingTrend trend;

  const _TrendBadge({
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (trend) {
      _StandingTrend.up => AppColors.emerald,
      _StandingTrend.down => AppColors.danger,
      _StandingTrend.stable =>
        Theme.of(context).textTheme.bodySmall?.color ?? AppColors.slate,
    };
    final icon = switch (trend) {
      _StandingTrend.up => Icons.arrow_upward_rounded,
      _StandingTrend.down => Icons.arrow_downward_rounded,
      _StandingTrend.stable => Icons.remove_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
