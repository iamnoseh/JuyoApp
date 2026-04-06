import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/features/profile/presentation/pages/profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel? user;
  final List<SkillProgressModel>? skills;
  final VoidCallback onRefresh;

  const ProfilePage({
    super.key,
    required this.user,
    this.skills,
    required this.onRefresh,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable Content
          RefreshIndicator(
            onRefresh: () async => widget.onRefresh(),
            backgroundColor: AppColors.aqua,
            color: Colors.white,
            edgeOffset: 120,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 120, 16, 100),
              children: [
                _buildIdentityCard(),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 16),
                _buildAdmissionGoalCard(),
                const SizedBox(height: 24),
                _buildSectionHeader('Навыки и прогресс', LucideIcons.activity),
                const SizedBox(height: 12),
                _buildSkillsList(),
                const SizedBox(height: 24),
                _buildSectionHeader('Последняя активность', LucideIcons.history),
                const SizedBox(height: 12),
                _buildRecentActivity(),
              ],
            ),
          ),

          // Shared Sticky Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: JuyoStickyHeader(
              streak: widget.user?.streak ?? 0,
              points: widget.user?.points ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: JuyoButton(
            text: 'РЕДАКТИРОВАТЬ',
            isSecondary: true,
            onPressed: widget.user == null
                ? null
                : () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileEditPage(user: widget.user!),
                      ),
                    );
                    widget.onRefresh();
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityCard() {
    final user = widget.user;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE3E9F2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.11), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Premium Ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100, height: 100,
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
                    child: user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty
                        ? Image.network(
                            user.profilePictureUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitials(user.fullName),
                          )
                        : _buildInitials(user?.fullName ?? ''),
                  ),
                ),
              ),
              if (user?.isPremium ?? false)
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
            user?.fullName ?? 'Загрузка...',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: AppColors.aqua),
              const SizedBox(width: 4),
              Text(
                user?.province ?? 'Душанбе',
                style: const TextStyle(color: AppColors.slate, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.school, user?.schoolName ?? 'Школа не выбрана'),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.graduationCap, user?.grade != null ? 'Класс: ${user!.grade}' : 'Класс не выбран'),
          const SizedBox(height: 14),
          _buildClusterCard(),
          const SizedBox(height: 14),
          const Divider(color: Colors.black12),
          const SizedBox(height: 10),
          _buildMetaRow(
            LucideIcons.calendarDays,
            'Присоединился: ${_formatDate(widget.user?.registrationDate)}',
          ),
          if (widget.user?.isPremium == true && (widget.user?.premiumExpiresAt?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            _buildMetaRow(
              LucideIcons.crown,
              'Premium до: ${_formatDate(widget.user?.premiumExpiresAt)}',
              color: AppColors.gold,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClusterCard() {
    final clusterText = widget.user?.clusterName ?? 'Не выбран';
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Ваш кластер', style: TextStyle(color: AppColors.slate, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(clusterText, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w800)),
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

  Widget _buildAdmissionGoalCard() {
    final user = widget.user;
    final university = user?.targetUniversity ?? 'Университет не выбран';
    final major = user?.targetMajorName ?? 'Специальность не выбрана';
    final score = user?.targetPassingScore?.toString() ?? '0';
    final score2024 = user?.targetPassingScore2024?.toString() ?? '—';
    final score2025 = user?.targetPassingScore2025?.toString() ?? '—';
    final probability = 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E9F2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ГОТОВНОСТЬ К',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ПОСТУПЛЕНИЮ',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 7),
                      ),
                    ),
                    SizedBox(
                      width: 74,
                      height: 74,
                      child: CircularProgressIndicator(
                        value: probability,
                        strokeWidth: 7,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.red),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    const Text(
                      '0%',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _goalLine(LucideIcons.graduationCap, 'ВЫБРАННЫЙ УНИВЕРСИТЕТ', university),
          const SizedBox(height: 12),
          _goalLine(LucideIcons.compass, 'СПЕЦИАЛЬНОСТЬ', major),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 16),
          const Text(
            'ПРОХОДНЫЕ БАЛЛЫ',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
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
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w900),
                ),
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
            Text(
              year,
              style: TextStyle(
                color: isTarget ? AppColors.gold : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: isTarget ? AppColors.gold : const Color(0xFF1E293B),
                fontSize: 28,
                height: 0.95,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.slate),
        const SizedBox(width: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.slate, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('Лига', widget.user?.currentLeagueName ?? 'Бронзовая', LucideIcons.trophy, Colors.amber),
        const SizedBox(width: 12),
        _buildStatItem('XP', '${widget.user?.xp ?? 0}', LucideIcons.zap, AppColors.aqua),
        const SizedBox(width: 12),
        _buildStatItem('Рейтинг', '№ ${widget.user?.globalRank ?? 0}', LucideIcons.globe, Colors.greenAccent),
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
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppColors.slate, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(String fullName) {
    if (fullName.isEmpty) return const SizedBox();
    final parts = fullName.split(' ');
    String initial = parts[0][0].toUpperCase();
    if (parts.length > 1) {
      initial += ' ${parts[1][0].toUpperCase()}';
    }
    return Center(
      child: Text(
        initial,
        style: const TextStyle(color: AppColors.navy, fontSize: 28, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.aqua),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(color: AppColors.navy, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildSkillsList() {
    final skills = widget.skills ?? [];
    if (skills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.milkyCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE3E9F2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: const Center(
          child: Text('Нет данных о навыках. Пройдите тесты!', style: TextStyle(color: AppColors.slate, fontSize: 13)),
        ),
      );
    }
    return Column(
      children: skills.map((skill) {
        final double percent = skill.proficiencyPercent.toDouble();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE3E9F2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 18, offset: const Offset(0, 8)),
            ],
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

  Widget _buildRecentActivity() {
    final tests = widget.user?.lastTestResults ?? [];
    if (tests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE3E9F2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 18, offset: const Offset(0, 8)),
          ],
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

    return Column(
      children: tests.map((test) => _buildActivityRow(test)).toList(),
    );
  }

  Widget _buildActivityRow(TestResultModel test) {
    String modeName = test.mode == 3 ? 'Дуэль' : test.mode == 2 ? 'Экзамен' : 'Тест';
    final bool success = test.totalScore > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E9F2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 18, offset: const Offset(0, 8)),
        ],
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
              Text(
                '${test.totalScore} баллов',
                style: TextStyle(color: success ? AppColors.gold : AppColors.red, fontWeight: FontWeight.w900, fontSize: 13),
              ),
              Text(
                success ? 'ЗАВЕРШЕНО' : 'НЕУДАЧНО',
                style: TextStyle(
                  color: success ? AppColors.slate : AppColors.red,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
