import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/constants/app_constants.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_event.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_state.dart';
import 'package:juyo/features/profile/presentation/cubit/profile_overview_cubit.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileRoutePage extends StatelessWidget {
  const ProfileRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
        ),
        BlocProvider(
          create: (_) => ProfileOverviewCubit(
            remoteDataSource: getIt<DashboardRemoteDataSource>(),
          )..load(),
        ),
      ],
      child: const _ProfileScreen(),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              current is ProfileFailure && current.message.isNotEmpty,
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        BlocListener<ProfileOverviewCubit, ProfileOverviewState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            final message = state.errorMessage;
            if (message == null || message.isEmpty) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          final profile = _profileFromState(profileState);

          return BlocBuilder<ProfileOverviewCubit, ProfileOverviewState>(
            builder: (context, overviewState) {
              return AppScaffold(
                topBar: AppTopStatsBar(
                  totalXp: profile?.xp,
                  streak: profile?.streak,
                ),
                title: '',
                showHeader: false,
                scrollable: false,
                child: _buildBody(
                  context,
                  profileState: profileState,
                  profile: profile,
                  overviewState: overviewState,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required ProfileState profileState,
    required Profile? profile,
    required ProfileOverviewState overviewState,
  }) {
    if ((profileState is ProfileInitial || profileState is ProfileLoading) &&
        profile == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.58,
        child: JuyoPageLoader(
          message: _tr(context, 'Загружаем профиль', 'Loading profile'),
        ),
      );
    }

    if (profileState is ProfileFailure && profile == null) {
      return ErrorState(
        title: _tr(context, 'Не удалось загрузить профиль', 'Failed to load profile'),
        subtitle: profileState.message,
        onRetry: () {
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
          context.read<ProfileOverviewCubit>().load();
        },
      );
    }

    if (profile == null) {
      return ErrorState(
        title: _tr(context, 'Профиль недоступен', 'Profile unavailable'),
        subtitle: _tr(
          context,
          'Попробуйте обновить страницу еще раз.',
          'Try refreshing the page once again.',
        ),
        onRetry: () {
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
          context.read<ProfileOverviewCubit>().load();
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.aqua,
      onRefresh: () async {
        context.read<ProfileBloc>().add(const ProfileRefreshRequested());
        await context.read<ProfileOverviewCubit>().load();
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          _ProfileHeroCard(
            profile: profile,
            onEdit: () {
              unawaited(_openEditProfile(context));
            },
          ),
          const SizedBox(height: 14),
          _ProfileStatsRow(profile: profile),
          const SizedBox(height: 14),
          _AdmissionMissionCard(
            profile: profile,
            admissionStats: overviewState.admissionStats,
          ),
          const SizedBox(height: 14),
          _AchievementCard(
            title: _tr(context, 'Достижения', 'Achievements'),
          ),
          const SizedBox(height: 14),
          _SkillsCard(
            title: _tr(context, 'Прогресс навыков', 'Skill progress'),
            subtitle: _tr(
              context,
              'По предметам, которые уже встречались в тестах',
              'Based on the subjects you have already practiced',
            ),
            isLoading: overviewState.isLoading && overviewState.skills.isEmpty,
            skills: overviewState.skills,
          ),
          const SizedBox(height: 14),
          _RecentTestsCard(
            profile: profile,
            title: _tr(context, 'Последние 5 тестов', 'Last 5 tests'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final updated = await context.push<bool>(AppRoutes.profileEdit);
    if (!context.mounted || updated != true) return;
    context.read<ProfileBloc>().add(const ProfileRefreshRequested());
    await context.read<ProfileOverviewCubit>().load();
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback onEdit;

  const _ProfileHeroCard({
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _avatarUrl(profile.avatarUrl);
    final fullName = _cleanText(profile.fullName, _tr(context, 'Пользователь', 'User'));
    final province = _cleanText(
      profile.province ?? '',
      _tr(context, 'Душанбе', 'Dushanbe'),
    );
    final schoolName = _cleanText(
      profile.schoolName ?? '',
      _tr(context, 'Школа не выбрана', 'School is not selected'),
    );
    final cluster = _cleanText(
      profile.clusterName ?? '',
      _tr(context, 'Не выбран', 'Not selected'),
    );
    final ageLabel = profile.age > 0
        ? _tr(context, '${profile.age} лет', '${profile.age} years old')
        : _tr(context, 'Возраст не указан', 'Age is not specified');

    return GlassCard(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: avatarUrl == null
                    ? null
                    : () => _openAvatarPreview(
                          context,
                          imageUrl: avatarUrl,
                          title: fullName,
                        ),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.aqua, AppColors.gold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: avatarUrl == null
                          ? _AvatarFallback(name: fullName)
                          : Image.network(
                              avatarUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _AvatarFallback(name: fullName),
                            ),
                    ),
                  ),
                ),
              ),
              if (profile.isPremium)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.32),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      'PRO',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: AppColors.aqua),
              const SizedBox(width: 6),
              Text(
                province,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$schoolName  •  $ageLabel',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF97316), AppColors.gold],
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AppPrimaryButton(
              label: _tr(context, 'Редактировать профиль', 'Edit profile'),
              icon: LucideIcons.pencil,
              onPressed: () {
                onEdit();
              },
            ),
          ),
          const SizedBox(height: 14),
          _InfoPill(
            icon: LucideIcons.sparkles,
            iconColor: AppColors.gold,
            title: _tr(context, 'Ваш кластер', 'Your cluster'),
            value: cluster,
            onTap: () {
              onEdit();
            },
          ),
          const SizedBox(height: 14),
          _MetaLine(
            icon: LucideIcons.calendarDays,
            text: _tr(
              context,
              'Присоединился: ${_formatDate(profile.registrationDate, context)}',
              'Joined: ${_formatDate(profile.registrationDate, context)}',
            ),
          ),
          if (profile.isPremium && (profile.premiumExpiresAt?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            _MetaLine(
              icon: LucideIcons.crown,
              text: _tr(
                context,
                'Premium до: ${_formatDate(profile.premiumExpiresAt, context)}',
                'Premium until: ${_formatDate(profile.premiumExpiresAt, context)}',
              ),
              color: AppColors.gold,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  final Profile profile;

  const _ProfileStatsRow({
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileStatCard(
            icon: LucideIcons.trophy,
            color: AppColors.gold,
            label: _tr(context, 'Лига', 'League'),
            value: _cleanText(
              profile.currentLeagueName ?? '',
              _tr(context, 'Бронзовая', 'Bronze'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProfileStatCard(
            icon: LucideIcons.flame,
            color: AppColors.emerald,
            label: 'XP',
            value: profile.xp.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProfileStatCard(
            icon: LucideIcons.activity,
            color: AppColors.aqua,
            label: _tr(context, 'Рейтинг', 'Rank'),
            value: profile.globalRank > 0 ? '#${profile.globalRank}' : '—',
          ),
        ),
      ],
    );
  }
}

class _AdmissionMissionCard extends StatelessWidget {
  final Profile profile;
  final AdmissionStatsModel? admissionStats;

  const _AdmissionMissionCard({
    required this.profile,
    required this.admissionStats,
  });

  @override
  Widget build(BuildContext context) {
    final probability = ((admissionStats?.admissionProbability ?? 0).toDouble())
        .clamp(0, 100);
    final progress = (probability / 100).clamp(0.0, 1.0);
    final status = (admissionStats?.status ?? 'Warning').toLowerCase();
    final accent = switch (status) {
      'safe' => AppColors.aqua,
      'danger' => AppColors.danger,
      _ => AppColors.gold,
    };

    final university = _cleanText(
      admissionStats?.targetUniversity ??
          admissionStats?.universityName ??
          profile.targetUniversity ??
          '',
      _tr(context, 'Университет не выбран', 'University not selected'),
    );
    final major = _cleanText(
      admissionStats?.targetMajorName ??
          admissionStats?.specialtyName ??
          profile.targetMajorName ??
          '',
      _tr(context, 'Специальность не выбрана', 'Major not selected'),
    );
    final score2024 = _displayScore(
      admissionStats?.targetPassingScore2024?.toInt() ?? profile.targetPassingScore2024,
    );
    final score2025 = _displayScore(
      admissionStats?.targetPassingScore2025?.toInt() ?? profile.targetPassingScore2025,
    );
    final targetScore = _displayScore(
      admissionStats?.targetPassingScore.toInt() ?? profile.targetPassingScore,
    );

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: _tr(context, 'Академическая миссия', 'Academic mission'),
            subtitle: _tr(
              context,
              'Цель и текущая готовность к поступлению',
              'Your target and current admission readiness',
            ),
            icon: LucideIcons.target,
            color: accent,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoPill(
                      icon: LucideIcons.graduationCap,
                      iconColor: AppColors.aqua,
                      title: _tr(context, 'Целевой университет', 'Target university'),
                      value: university,
                    ),
                    const SizedBox(height: 10),
                    _InfoPill(
                      icon: LucideIcons.bookOpen,
                      iconColor: AppColors.gold,
                      title: _tr(context, 'Специальность', 'Major'),
                      value: major,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: accent.withValues(alpha: 0.12),
                        color: accent,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${probability.round()}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                        ),
                        Text(
                          _tr(context, 'шанс', 'chance'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ScoreItem(
                  year: '2024',
                  value: score2024,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ScoreItem(
                  year: '2025',
                  value: score2025,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ScoreItem(
                  year: _tr(context, 'Цель', 'Goal'),
                  value: targetScore,
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;

  const _AchievementCard({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _AchievementItem(icon: LucideIcons.star, color: AppColors.gold, unlocked: true),
      _AchievementItem(icon: LucideIcons.trophy, color: AppColors.aqua, unlocked: true),
      _AchievementItem(icon: LucideIcons.layout, color: AppColors.emerald, unlocked: true),
      _AchievementItem(icon: LucideIcons.flame, color: AppColors.gold, unlocked: false),
      _AchievementItem(icon: LucideIcons.award, color: AppColors.aqua, unlocked: false),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: title,
            subtitle: _tr(
              context,
              '${items.where((item) => item.unlocked).length} / ${items.length} открыто',
              '${items.where((item) => item.unlocked).length} / ${items.length} unlocked',
            ),
            icon: LucideIcons.award,
            color: AppColors.gold,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items
                .map(
                  (item) => _AchievementDot(
                    icon: item.icon,
                    color: item.color,
                    unlocked: item.unlocked,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLoading;
  final List<SkillProgressModel> skills;

  const _SkillsCard({
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: title,
            subtitle: subtitle,
            icon: LucideIcons.activity,
            color: AppColors.aqua,
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: AppColors.aqua),
              ),
            )
          else if (skills.isEmpty)
            _EmptySection(
              title: _tr(
                context,
                'Пока нет данных по навыкам',
                'There is no skill data yet',
              ),
              subtitle: _tr(
                context,
                'Пройдите тесты, чтобы мы показали реальный прогресс по предметам.',
                'Complete tests and we will show your real progress by subject.',
              ),
              onPressed: () => context.go(AppRoutes.tests),
              buttonLabel: _tr(context, 'Открыть тесты', 'Open tests'),
            )
          else
            Column(
              children: skills
                  .map(
                    (skill) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SkillRow(skill: skill),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _RecentTestsCard extends StatelessWidget {
  final Profile profile;
  final String title;

  const _RecentTestsCard({
    required this.profile,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final items = profile.lastTestResults.take(5).toList();
    final lastFinishedAt = items.isEmpty ? null : items.first.finishedAt;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: title,
            subtitle: lastFinishedAt == null
                ? _tr(
                    context,
                    'История последних попыток',
                    'History of your latest attempts',
                  )
                : _tr(
                    context,
                    'Последний: ${_formatDate(lastFinishedAt, context)}',
                    'Latest: ${_formatDate(lastFinishedAt, context)}',
                  ),
            icon: LucideIcons.history,
            color: AppColors.emerald,
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _EmptySection(
              title: _tr(
                context,
                'Вы еще не проходили тесты',
                'You have not completed tests yet',
              ),
              subtitle: _tr(
                context,
                'Когда появятся попытки, последние 5 результатов будут показаны здесь.',
                'Once you start taking tests, your latest 5 results will appear here.',
              ),
              onPressed: () => context.go(AppRoutes.tests),
              buttonLabel: _tr(context, 'Начать тест', 'Start a test'),
            )
          else
            Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TestHistoryRow(item: item),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _ProfileStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.18),
                color.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoPill({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withValues(alpha: 0.12),
            iconColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () {
        onTap!();
      },
      child: child,
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MetaLine({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String year;
  final String value;
  final bool highlight;

  const _ScoreItem({
    required this.year,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = highlight ? AppColors.gold : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: highlight
              ? [
                  AppColors.gold.withValues(alpha: 0.16),
                  AppColors.gold.withValues(alpha: 0.08),
                ]
              : [
                  Colors.white.withValues(alpha: 0.62),
                  Colors.white.withValues(alpha: 0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(
            year,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: highlight ? AppColors.gold : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final SkillProgressModel skill;

  const _SkillRow({
    required this.skill,
  });

  @override
  Widget build(BuildContext context) {
    final percent = skill.proficiencyPercent.clamp(0, 100).toDouble();
    final palette = <Color>[
      AppColors.aqua,
      AppColors.gold,
      AppColors.emerald,
      const Color(0xFFFB7185),
      const Color(0xFF818CF8),
      const Color(0xFF22C55E),
    ];
    final seed = skill.subjectName.runes.fold<int>(0, (sum, rune) => sum + rune);
    final color = palette[seed % palette.length];
    final badgeLabel = percent >= 70
        ? _tr(context, 'Эксперт', 'Expert')
        : _tr(context, 'Средний', 'Medium');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _cleanText(skill.subjectName, _tr(context, 'Предмет', 'Subject')),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${skill.correctAnswers}/${skill.totalQuestions} ${_tr(context, 'правильных', 'correct')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '${skill.proficiencyPercent}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final String buttonLabel;

  const _EmptySection({
    required this.title,
    required this.subtitle,
    required this.onPressed,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.auto_graph_rounded, size: 34, color: AppColors.aqua),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        AppSecondaryButton(
          label: buttonLabel,
          icon: LucideIcons.arrowRight,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class _TestHistoryRow extends StatelessWidget {
  final ProfileTestResult item;

  const _TestHistoryRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _modeMeta(context, item.mode);
    final success = item.totalScore > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(meta.icon, size: 18, color: meta.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(item.finishedAt, context),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (item.subjectName != null && item.subjectName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.subjectName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.totalScore} ${_tr(context, 'баллов', 'pts')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: success ? AppColors.gold : AppColors.danger,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (success ? AppColors.emerald : AppColors.danger)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  success
                      ? _tr(context, 'Завершено', 'Completed')
                      : _tr(context, 'Неудачно', 'Failed'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: success ? AppColors.emerald : AppColors.danger,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementDot extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool unlocked;

  const _AchievementDot({
    required this.icon,
    required this.color,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: unlocked
              ? [
                  color.withValues(alpha: 0.24),
                  color.withValues(alpha: 0.1),
                ]
              : [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.06),
                ],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 20,
        color: unlocked ? color : Theme.of(context).textTheme.bodySmall?.color,
      ),
    );
  }
}

class _AchievementItem {
  final IconData icon;
  final Color color;
  final bool unlocked;

  const _AchievementItem({
    required this.icon,
    required this.color,
    required this.unlocked,
  });
}

class _AvatarFallback extends StatelessWidget {
  final String name;

  const _AvatarFallback({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.aqua.withValues(alpha: 0.18),
            AppColors.gold.withValues(alpha: 0.16),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _ModeMeta {
  final String label;
  final IconData icon;
  final Color color;

  const _ModeMeta({
    required this.label,
    required this.icon,
    required this.color,
  });
}

Profile? _profileFromState(ProfileState state) {
  return switch (state) {
    ProfileLoaded(:final profile) => profile,
    ProfileSaving(:final profile?) => profile,
    ProfileUpdateSuccess(:final profile) => profile,
    ProfileFailure(profile: final profile?) => profile,
    _ => null,
  };
}

Future<void> _openAvatarPreview(
  BuildContext context, {
  required String imageUrl,
  required String title,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _tr(BuildContext context, String ru, String en) =>
    Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

String _cleanText(String raw, String fallback) {
  final value = raw.trim();
  if (value.isEmpty || value.contains('Ã') || value.contains('Ã¢')) {
    return fallback;
  }
  return value;
}

String _displayScore(int? value) {
  if (value == null || value <= 0) return '—';
  return value.toString();
}

String _formatDate(String? iso, BuildContext context) {
  if (iso == null || iso.trim().isEmpty) return '—';
  final date = DateTime.tryParse(iso);
  if (date == null) return iso;
  const ruMonths = [
    'янв',
    'фев',
    'мар',
    'апр',
    'май',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  const enMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final months =
      Localizations.localeOf(context).languageCode == 'ru' ? ruMonths : enMonths;
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatDateTime(String? iso, BuildContext context) {
  if (iso == null || iso.trim().isEmpty) return '—';
  final date = DateTime.tryParse(iso);
  if (date == null) return iso;
  final datePart = _formatDate(iso, context);
  final hours = date.hour.toString().padLeft(2, '0');
  final minutes = date.minute.toString().padLeft(2, '0');
  return '$datePart • $hours:$minutes';
}

String _initials(String name) {
  final parts = name
      .split(RegExp(r'\s+'))
      .where((item) => item.isNotEmpty)
      .take(2)
      .map((item) => item.substring(0, 1).toUpperCase())
      .toList();
  return parts.isEmpty ? 'J' : parts.join();
}

String? _avatarUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;
  final host = AppConstants.apiBaseUrl.replaceFirst('/api', '');
  return rawUrl.startsWith('/') ? '$host$rawUrl' : '$host/$rawUrl';
}

_ModeMeta _modeMeta(BuildContext context, int mode) {
  return switch (mode) {
    3 => _ModeMeta(
        label: _tr(context, 'Дуэль', 'Duel'),
        icon: LucideIcons.trophy,
        color: AppColors.gold,
      ),
    2 => _ModeMeta(
        label: _tr(context, 'Экзамен', 'Exam'),
        icon: LucideIcons.layout,
        color: AppColors.emerald,
      ),
    4 => _ModeMeta(
        label: _tr(context, 'По предметам', 'By subject'),
        icon: LucideIcons.bookOpen,
        color: AppColors.aqua,
      ),
    _ => _ModeMeta(
        label: _tr(context, 'Практика', 'Practice'),
        icon: LucideIcons.bookOpen,
        color: AppColors.aqua,
      ),
  };
}
