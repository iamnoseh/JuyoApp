import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_event.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_state.dart';
import 'package:juyo/features/profile/presentation/mappers/profile_seed_mapper.dart';
import 'package:juyo/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_bloc.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_event.dart';

class ProfilePage extends StatelessWidget {
  final UserModel? user;
  final List<SkillProgressModel>? skills;
  final VoidCallback onRefresh;
  final ValueChanged<int>? onNavigateTab;
  final double topInset;
  final double bottomInset;

  const ProfilePage({
    super.key,
    required this.user,
    this.skills,
    required this.onRefresh,
    this.onNavigateTab,
    this.topInset = 120,
    this.bottomInset = 100,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<ProfileBloc>();
        if (user != null) {
          bloc.add(ProfileSeeded(ProfileSeedMapper.fromUserModel(user!)));
          bloc.add(const ProfileRefreshRequested());
        } else {
          bloc.add(const ProfileLoadRequested());
        }
        return bloc;
      },
      child: _ProfileView(
        skills: skills ?? const [],
        onRefresh: onRefresh,
        onNavigateTab: onNavigateTab,
        topInset: topInset,
        bottomInset: bottomInset,
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final List<SkillProgressModel> skills;
  final VoidCallback onRefresh;
  final ValueChanged<int>? onNavigateTab;
  final double topInset;
  final double bottomInset;

  const _ProfileView({
    required this.skills,
    required this.onRefresh,
    required this.onNavigateTab,
    required this.topInset,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) => current is ProfileFailure,
      listener: (context, state) {
        if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final profile = switch (state) {
          ProfileLoaded(:final profile) => profile,
          ProfileSaving(:final profile?) => profile,
          ProfileUpdateSuccess(:final profile) => profile,
          ProfileFailure(profile: final profile?) => profile,
          _ => null,
        };

        final isLoading = state is ProfileInitial || state is ProfileLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(const ProfileRefreshRequested());
                  onRefresh();
                },
                backgroundColor: AppColors.aqua,
                color: Colors.white,
                edgeOffset: topInset,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, topInset, 16, bottomInset),
                  children: [
                    if (isLoading && profile == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.aqua),
                        ),
                      )
                    else ...[
                      _buildIdentityCard(profile),
                      const SizedBox(height: 12),
                      _buildQuickActions(context, profile),
                      const SizedBox(height: 20),
                      _buildStatsRow(profile),
                      const SizedBox(height: 16),
                      _buildAdmissionGoalCard(profile),
                      const SizedBox(height: 24),
                      _buildSectionHeader('НАВЫКИ И ПРОГРЕСС', LucideIcons.activity),
                      const SizedBox(height: 12),
                      _buildSkillsList(skills),
                      const SizedBox(height: 24),
                      _buildSectionHeader('ПОСЛЕДНЯЯ АКТИВНОСТЬ', LucideIcons.history),
                      const SizedBox(height: 12),
                      _buildRecentActivity(profile),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: JuyoStickyHeader(
                  streak: profile?.streak ?? 0,
                  points: profile?.points ?? 0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, Profile? profile) {
    return Row(
      children: [
        Expanded(
          child: JuyoButton(
            text: 'РЕДАКТИРОВАТЬ',
            isSecondary: true,
            onPressed: profile == null
                ? null
                : () async {
                    final bloc = context.read<ProfileBloc>();
                    final result = await Navigator.of(context).push<dynamic>(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: bloc),
                            BlocProvider(
                              create: (_) => getIt<ReferenceBloc>()
                                ..add(
                                  ReferenceLoadRequested(
                                    selectedUniversityId: profile.targetUniversityId,
                                  ),
                                ),
                            ),
                          ],
                          child: ProfileEditPage(profile: profile),
                        ),
                      ),
                    );

                    if (result == true) {
                      onRefresh();
                    }

                    if (result is int) {
                      onNavigateTab?.call(result);
                    }
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityCard(Profile? profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE3E9F2)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.aqua, AppColors.gold]),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                  ),
                  child: ClipOval(
                    child: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                        ? Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitials(profile.fullName),
                          )
                        : _buildInitials(profile?.fullName ?? ''),
                  ),
                ),
              ),
              if (profile?.isPremium ?? false)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('PRO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile?.fullName ?? 'Загрузка...',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: AppColors.aqua),
              const SizedBox(width: 4),
              Text(
                profile?.province ?? 'Душанбе',
                style: const TextStyle(color: AppColors.slate, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.school, profile?.schoolName ?? 'Школа не выбрана'),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.graduationCap, profile?.grade != null ? 'Класс: ${profile!.grade}' : 'Класс не выбран'),
          const SizedBox(height: 14),
          _buildClusterCard(profile),
          const SizedBox(height: 14),
          const Divider(color: Colors.black12),
          const SizedBox(height: 10),
          _buildMetaRow(LucideIcons.calendarDays, 'Присоединился: ${_formatDate(profile?.registrationDate)}'),
          if (profile?.isPremium == true && (profile?.premiumExpiresAt?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            _buildMetaRow(
              LucideIcons.crown,
              'Premium до: ${_formatDate(profile?.premiumExpiresAt)}',
              color: AppColors.gold,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClusterCard(Profile? profile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.sparkles, size: 16, color: AppColors.gold),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              const Text('Ваш кластер', style: TextStyle(color: AppColors.slate, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                profile?.clusterName ?? 'Не выбран',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text, {Color color = AppColors.slate}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    );
  }

  Widget _buildAdmissionGoalCard(Profile? profile) {
    final university = profile?.targetUniversity ?? 'Университет не выбран';
    final major = profile?.targetMajorName ?? 'Специальность не выбрана';
    final score = profile?.targetPassingScore?.toString() ?? '0';
    final score2024 = profile?.targetPassingScore2024?.toString() ?? '—';
    final score2025 = profile?.targetPassingScore2025?.toString() ?? '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E9F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ГОТОВНОСТЬ К ПОСТУПЛЕНИЮ', style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          _goalLine(LucideIcons.graduationCap, 'ВЫБРАННЫЙ УНИВЕРСИТЕТ', university),
          const SizedBox(height: 12),
          _goalLine(LucideIcons.compass, 'СПЕЦИАЛЬНОСТЬ', major),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 16),
          const Text('ПРОХОДНЫЕ БАЛЛЫ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            children: [
              _scoreChip('2024', score2024),
              const SizedBox(width: 8),
              _scoreChip('2025', score2025),
              const SizedBox(width: 8),
              _scoreChip('ЦЕЛЬ', score, isTarget: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalLine(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E6EE)),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreChip(String year, String value, {bool isTarget = false}) {
    return Expanded(
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: isTarget ? AppColors.gold.withValues(alpha: 0.12) : AppColors.milkyCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isTarget ? AppColors.gold : const Color(0xFFE2E8F0), width: isTarget ? 1.5 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(year, style: TextStyle(color: isTarget ? AppColors.gold : const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(color: isTarget ? AppColors.gold : const Color(0xFF1E293B), fontSize: 22, height: 0.95, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.slate),
        const SizedBox(width: 12),
        Flexible(child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.slate, fontSize: 14, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildStatsRow(Profile? profile) {
    return Row(
      children: [
        _buildStatItem('Лига', profile?.currentLeagueName ?? 'Бронзовая', LucideIcons.trophy, Colors.amber),
        const SizedBox(width: 12),
        _buildStatItem('XP', '${profile?.xp ?? 0}', LucideIcons.zap, AppColors.aqua),
        const SizedBox(width: 12),
        _buildStatItem('Рейтинг', '№ ${profile?.globalRank ?? 0}', LucideIcons.globe, Colors.greenAccent),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppColors.slate, fontSize: 10, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(value, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(String fullName) {
    if (fullName.isEmpty) return const SizedBox();
    final parts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    var initial = parts.first[0].toUpperCase();
    if (parts.length > 1) {
      initial += ' ${parts[1][0].toUpperCase()}';
    }
    return Center(
      child: Text(initial, style: const TextStyle(color: AppColors.navy, fontSize: 28, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.aqua),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildSkillsList(List<SkillProgressModel> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.milkyCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE3E9F2)),
        ),
        child: const Center(
          child: Text('Нет данных о навыках. Пройдите тесты!', style: TextStyle(color: AppColors.slate, fontSize: 13)),
        ),
      );
    }

    return Column(
      children: items.map((skill) {
        final percent = skill.proficiencyPercent.toDouble();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE3E9F2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(skill.subjectName, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
                  Text('${skill.proficiencyPercent}%', style: const TextStyle(color: AppColors.aqua, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: percent > 70 ? AppColors.aqua : AppColors.gold,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(Profile? profile) {
    final tests = profile?.lastTestResults ?? const <ProfileTestResult>[];
    if (tests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE3E9F2)),
        ),
        child: const Center(
          child: Text(
            'История тестов пуста.\nПройдите свой первый тест!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slate, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Column(children: tests.map(_buildActivityRow).toList());
  }

  Widget _buildActivityRow(ProfileTestResult test) {
    final modeName = test.mode == 3 ? 'Дуэль' : test.mode == 2 ? 'Экзамен' : 'Тест';
    final success = test.totalScore > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E9F2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: Icon(test.mode == 3 ? LucideIcons.trophy : LucideIcons.bookOpen, size: 18, color: AppColors.aqua),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modeName.toUpperCase(), style: const TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.w900)),
                if (test.subjectName != null)
                  Text(test.subjectName!, style: const TextStyle(color: AppColors.slate, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${test.totalScore} баллов', style: TextStyle(color: success ? AppColors.gold : AppColors.red, fontWeight: FontWeight.w900, fontSize: 13)),
              Text(success ? 'ЗАВЕРШЕНО' : 'НЕУДАЧНО', style: TextStyle(color: success ? AppColors.slate : AppColors.red, fontSize: 9, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
