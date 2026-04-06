import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_event.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/league_leaderboard_model.dart';
import 'package:juyo/features/home/domain/entities/dashboard_data.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_event.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_state.dart';
import 'package:juyo/features/profile/presentation/pages/profile_page.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _dockHeight = 66.0;
  static const _topHeight = 92.0;
  static const _cardRadius = 28.0;

  int _selectedIndex = 0;
  bool _isMenuOpen = false;
  bool _isLoading = true;

  UserModel? _user;
  DashboardMotivation _motivation = const DashboardMotivation(
    content: 'Загрузка...',
    author: '',
  );
  DashboardStatsModel? _dashboardStats;
  AdmissionStatsModel? _admissionStats;
  List<LeagueLeaderboardModel> _leaderboard = [];
  List<SkillProgressModel> _skills = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<DashboardBloc>().state is DashboardInitial) {
        context.read<DashboardBloc>().add(const DashboardLoadRequested());
      }
    });
  }

  Future<void> _refresh() async {
    context.read<DashboardBloc>().add(const DashboardRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          _isLoading = true;
        } else if (state is DashboardLoaded) {
          _user = state.data.user;
          _motivation = state.data.motivation;
          _dashboardStats = state.data.dashboardStats;
          _admissionStats = state.data.admissionStats;
          _leaderboard = state.data.leaderboard;
          _skills = state.data.skills;
          _isLoading = false;
        } else if (state is DashboardFailure) {
          _isLoading = false;
        }

        return _buildBody(context);
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    const topInset = _topHeight + 24;
    final bottomInset = MediaQuery.of(context).padding.bottom + _dockHeight + 28;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.aqua),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: JuyoBottomDock(
          currentIndex: _selectedIndex,
          isMenuOpen: _isMenuOpen,
          onToggleMenu: () => setState(() => _isMenuOpen = !_isMenuOpen),
          onTap: (index) => setState(() {
            _selectedIndex = index;
            _isMenuOpen = false;
          }),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex == 3 ? 1 : 0,
              children: [
                RefreshIndicator(
                  onRefresh: _refresh,
                  edgeOffset: topInset,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      topInset + 8,
                      16,
                      bottomInset,
                    ),
                    children: [
                      _welcomeCard(),
                      const SizedBox(height: 16),
                      _admissionCard(),
                      const SizedBox(height: 16),
                      _dailyGoalsCard(),
                      const SizedBox(height: 16),
                      _statsGrid(),
                      const SizedBox(height: 16),
                      _leaderboardCard(),
                    ],
                  ),
                ),
                ProfilePage(
                  user: _user,
                  skills: _skills,
                  onRefresh: _refresh,
                  onNavigateTab: (index) => setState(() => _selectedIndex = index),
                  topInset: topInset,
                  bottomInset: bottomInset,
                ),
              ],
            ),
          ),
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isMenuOpen = false),
                child: Container(color: Colors.black.withValues(alpha: 0.35)),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            top: _isMenuOpen ? 0 : -MediaQuery.of(context).size.height * 0.42,
            left: 0,
            right: 0,
            child: _topMenu(context),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: JuyoStickyHeader(
              streak: _user?.streak ?? 0,
              points: _user?.xp ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'С возвращением,\n${_displayName()}!',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _welcomeTitleFontSize(),
                        height: 1.06,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '«${_motivationContent()}»',
                      style: TextStyle(
                        fontSize: _welcomeQuoteFontSize(),
                        height: _welcomeQuoteLineHeight(),
                        color: AppColors.slate,
                      ),
                    ),
                    if (_motivationAuthor().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFFFB45B),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '— ${_motivationAuthor()}',
                          style: TextStyle(
                            fontSize: _welcomeAuthorFontSize(),
                            height: 1.3,
                            color: const Color(0xFF7A8699),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _refresh,
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEB7B00),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEB7B00).withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Продолжить обучение',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.arrowRight,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _admissionCard() {
    final probability = ((_admissionStats?.admissionProbability ?? 0).toDouble())
        .clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Готовность к\nпоступлению',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C2434),
                  ),
                ),
              ),
              _progressRing(probability),
            ],
          ),
          const SizedBox(height: 18),
          _admissionInfoRow(
            icon: LucideIcons.graduationCap,
            label: 'Выбранный университет',
            value: _admissionStats?.targetUniversity ??
                _admissionStats?.universityName ??
                _user?.targetUniversity ??
                'Не выбрано',
          ),
          const SizedBox(height: 12),
          _admissionInfoRow(
            icon: LucideIcons.bookOpen,
            label: 'Специальность',
            value: _admissionStats?.targetMajorName ??
                _admissionStats?.specialtyName ??
                _user?.targetMajorName ??
                'Не выбрано',
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFE8EDF5)),
          const SizedBox(height: 14),
          const Text(
            'Проходные баллы',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8A94A6),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _scoreBox(
                  '2024',
                  _formatScore(
                    _admissionStats?.targetPassingScore2024 ??
                        _user?.targetPassingScore2024,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _scoreBox(
                  '2025',
                  _formatScore(
                    _admissionStats?.targetPassingScore2025 ??
                        _user?.targetPassingScore2025,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _scoreBox(
                  'Цель',
                  _formatScore(
                    _admissionStats?.targetPassingScore != 0
                        ? _admissionStats?.targetPassingScore
                        : _user?.targetPassingScore,
                  ),
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dailyGoalsCard() {
    final completed = _dashboardStats?.dailyProgress.completed ?? 0;
    final goal = _dashboardStats?.dailyProgress.goal ?? 5;
    final progress = goal > 0 ? (completed / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Цели на сегодня',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C2434),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FD),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$completed/$goal тестов пройдено',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2A3344),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D6CDF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE7ECF5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2D6CDF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: tileWidth,
              child: _statTile(
                icon: LucideIcons.fileQuestion,
                iconColor: const Color(0xFF2D6CDF),
                label: 'Тесты',
                value:
                    '${_admissionStats?.relevantTestsCount ?? _dashboardStats?.dailyProgress.completed ?? 0}',
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: _statTile(
                icon: LucideIcons.zap,
                iconColor: const Color(0xFFFF8A00),
                label: 'XP',
                value: '${_user?.xp ?? 0}',
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: _statTile(
                icon: LucideIcons.award,
                iconColor: const Color(0xFFFFA22D),
                label: 'Рейтинг',
                value: '${_user?.eloRating ?? 0}',
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: _statTile(
                icon: LucideIcons.target,
                iconColor: const Color(0xFF2D6CDF),
                label: 'Точность',
                value: '${_averageAccuracy()}%',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _leaderboardCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _leagueTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1C2434),
                  ),
                ),
              ),
              const Text(
                'Смотреть все',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D6CDF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_leaderboard.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FD),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Нет данных',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate,
                ),
              ),
            )
          else
            ..._leaderboard.take(5).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _leaderboardRow(item),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _admissionInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F6FB),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: const Color(0xFF7D8798)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.4,
                  color: Color(0xFF9AA3B2),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.25,
                  color: Color(0xFF232D3D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressRing(double probability) {
    final progress = (probability / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: const Color(0xFFE9EDF5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE3A548),
              ),
            ),
          ),
          Text(
            '${probability.round()}%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5F6776),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreBox(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFF7F0) : const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(18),
        border: highlight
            ? Border.all(color: const Color(0xFFFFA24D), width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: highlight
                  ? const Color(0xFFFF8A00)
                  : const Color(0xFF8A94A6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: highlight ? 22 : 20,
              fontWeight: FontWeight.w900,
              color: highlight
                  ? const Color(0xFFFF8A00)
                  : const Color(0xFF20293A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaderboardRow(LeagueLeaderboardModel item) {
    final highlight = item.isMe;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFF3E3) : const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(18),
        border: highlight
            ? Border.all(color: const Color(0xFFFFD08B), width: 1)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${item.rank}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: highlight
                    ? const Color(0xFFFF8A00)
                    : const Color(0xFF4B5563),
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: highlight
                  ? const Color(0xFFFFD59C)
                  : const Color(0xFFE6EBF4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: highlight
                    ? const Color(0xFF7C4A00)
                    : const Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            item.xp,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: highlight
                  ? const Color(0xFFFF8A00)
                  : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_cardRadius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A23324A),
          blurRadius: 26,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  String _displayName() {
    final fullName = (_user?.fullName ?? '').trim();
    if (fullName.isEmpty) return 'студент';

    final parts = fullName.split(RegExp(r'\s+'));
    return parts.first;
  }

  String _motivationContent() {
    final value = _motivation.content.trim();
    if (value.isEmpty || value.contains('Ð')) {
      return 'Твой интеллект растет каждый день. Продолжай обучение.';
    }
    return value;
  }

  String _motivationAuthor() {
    final value = _motivation.author.trim();
    if (value.isEmpty || value.contains('Ð')) {
      return '';
    }
    return value;
  }

  double _welcomeTitleFontSize() {
    final nameLength = _displayName().length;
    if (nameLength >= 16) return 18;
    if (nameLength >= 11) return 20;
    return 22;
  }

  double _welcomeQuoteFontSize() {
    final contentLength = _motivationContent().length;
    if (contentLength >= 180) return 11;
    if (contentLength >= 130) return 12;
    return 13;
  }

  double _welcomeQuoteLineHeight() {
    final contentLength = _motivationContent().length;
    if (contentLength >= 180) return 1.32;
    return 1.4;
  }

  double _welcomeAuthorFontSize() {
    final authorLength = _motivationAuthor().length;
    if (authorLength >= 22) return 11;
    return 12;
  }

  String _formatScore(num? value) {
    if (value == null) return '—';
    final score = value.toDouble();
    if (score <= 0) return '—';
    if (score == score.roundToDouble()) {
      return score.round().toString();
    }
    return score.toStringAsFixed(1);
  }

  int _averageAccuracy() {
    final performances =
        _dashboardStats?.subjectPerformance ?? const <SubjectPerformanceModel>[];
    if (performances.isEmpty) return 0;

    final total = performances.fold<int>(0, (sum, item) => sum + item.score);
    return (total / performances.length).round().clamp(0, 100);
  }

  String _leagueTitle() {
    final league = (_user?.currentLeagueName ?? '').trim();
    if (league.isEmpty) return 'Бронзовая лига';

    final lower = league.toLowerCase();
    if (lower.contains('лига') || lower.contains('league')) {
      return league;
    }
    return '$league лига';
  }

  Widget _topMenu(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.34,
      decoration: BoxDecoration(
        color: const Color(0xFF343F51).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            children: [
              const Text(
                'JUYO MENU',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _menuItem(LucideIcons.listTodo, 'Красный\nсписок'),
                  ),
                  Expanded(
                    child: _menuItem(LucideIcons.trophy, 'Рейтинг\nлиги'),
                  ),
                  Expanded(
                    child: _menuItem(LucideIcons.building2, 'Рейтинг\nшкол'),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 180,
                height: 40,
                child: JuyoButton(
                  text: 'Выйти',
                  isDanger: true,
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLoggedOut());
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class JuyoBottomDock extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;

  const JuyoBottomDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isMenuOpen,
    required this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    final slot = (MediaQuery.of(context).size.width - 32) / 5;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3545),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              _item(slot, LucideIcons.layoutDashboard, 'ПАРАМ', 0),
              _item(slot, LucideIcons.swords, 'ДУЭЛЬ', 1),
              SizedBox(
                width: slot,
                child: GestureDetector(
                  onTap: onToggleMenu,
                  child: Icon(
                    isMenuOpen ? LucideIcons.x : LucideIcons.layoutGrid,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
              ),
              _item(slot, LucideIcons.brain, 'ТЕСТЫ', 2),
              _item(slot, LucideIcons.user, 'ПРОФИЛЬ', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(double width, IconData icon, String label, int index) {
    final active = currentIndex == index && !isMenuOpen;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? AppColors.gold : const Color(0xFFAEB8C8),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: active ? AppColors.gold : const Color(0xFFAEB8C8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
