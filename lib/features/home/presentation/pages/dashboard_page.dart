import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/auth/presentation/pages/login_page.dart';
import 'package:juyo/core/services/auth_service.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/services/user_service.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';
import 'package:juyo/features/home/data/datasources/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  UserModel? _user;
  String _motivation = 'Загрузка мудрости...';
  DashboardStatsModel? _dashboardStats;
  AdmissionStatsModel? _admissionStats;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        UserService.fetchProfile(),
        DashboardService.fetchMotivation(),
        DashboardService.fetchStudentStats(),
        DashboardService.fetchAdmissionStats(),
      ]);

      if (mounted) {
        setState(() {
          _user = results[0] as UserModel?;
          _motivation = results[1] as String;
          _dashboardStats = results[2] as DashboardStatsModel?;
          _admissionStats = results[3] as AdmissionStatsModel?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.aqua),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16, 0, 16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: JuyoBottomDock(
          currentIndex: _selectedIndex,
          isMenuOpen: _isMenuOpen,
          onToggleMenu: _toggleMenu,
          onTap: (index) {
            if (_isMenuOpen) _toggleMenu();
            setState(() => _selectedIndex = index);
          },
        ),
      ),
      body: Stack(
        children: [
          // 1. Scrollable Body
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              backgroundColor: AppColors.navy,
              color: AppColors.aqua,
              displacement: 110,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.only(top: 130, bottom: 40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _isLoading ? _buildJuyoLoading() : WelcomeCard(
                        firstName: _user?.fullName.split(' ').first ?? 'Пользователь',
                        motivation: _motivation,
                      ),
                      const SizedBox(height: 18),
                      StatsSection(
                        dashboardStats: _dashboardStats,
                        admissionStats: _admissionStats,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Menu Backdrop (Closes on tap)
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),
              ),
            ),

          // 3. Animated Top Menu
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            top: _isMenuOpen ? 0 : -MediaQuery.of(context).size.height * 0.8,
            left: 0,
            right: 0,
            child: _buildTopMenuOverlay(context),
          ),

          // 4. Sticky Header (Branding only)
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C3545),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Opacity(opacity: 0, child: Icon(LucideIcons.menu)), // Hidden spacer
                      const Text(
                        'JUYO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                        ),
                      ),
                      Row(
                        children: [
                          _buildTopBadge(LucideIcons.coins, '2,450', AppColors.gold),
                          const SizedBox(width: 8),
                          _buildTopBadge(LucideIcons.flame, '12', Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenuOverlay(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.75;
    const Color juyoNavy = Color(0xFF343F51);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: juyoNavy.withOpacity(0.98),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 20)),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: SafeArea(
          child: Column(
            children: [
              // Branding & Profile Section
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
                child: Column(
                  children: [
                    const Text('JUYO', style: TextStyle(color: AppColors.aqua, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8.0)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [AppColors.aqua, AppColors.gold]),
                      ),
                      child: Container(
                        width: 84, height: 84,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: juyoNavy,
                          image: DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?u=alisher'), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('АЛИШЕР НАЗАРОВ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Divider(color: Colors.white10),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildTopMenuItem(LucideIcons.listTodo, 'КРАСНЫЙ СПИСОК', isLocked: true),
                    _buildTopMenuItem(LucideIcons.trophy, 'РЕЙТИНГ ЛИГИ'),
                    _buildTopMenuItem(LucideIcons.building2, 'РЕЙТИНГ ШКОЛ'),
                    _buildTopMenuItem(LucideIcons.zap, 'PREMIUM JUYO', isPremium: true),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(36, 10, 36, 30),
                child: JuyoButton(
                  text: 'ВЫЙТИ',
                  isDanger: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopMenuItem(IconData icon, String title, {bool isLocked = false, bool isPremium = false}) {
    return ListTile(
      leading: Icon(icon, color: isPremium ? AppColors.gold : Colors.white60, size: 20),
      title: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
      trailing: isLocked ? const Icon(LucideIcons.lock, size: 14, color: Colors.white24) : null,
      onTap: () {},
    );
  }

  Widget _buildJuyoLoading() {
    return Container(
      height: 140,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: const Icon(LucideIcons.brain, color: AppColors.aqua, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'JUYO',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 4.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text('ОБНОВЛЯЕМ...', style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildTopBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  final String firstName;
  final String motivation;

  const WelcomeCard({
    super.key,
    required this.firstName,
    required this.motivation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, 12)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Привет,\n$firstName!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.1, color: AppColors.navy)),
                const SizedBox(height: 10),
                Text('«$motivation»', style: const TextStyle(color: Colors.black45, fontSize: 11, fontStyle: FontStyle.italic)),
                const SizedBox(height: 18),
                SizedBox(height: 44, width: 140, child: JuyoButton(text: 'Обучение', onPressed: () {})),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Icon(LucideIcons.brain, size: 58, color: AppColors.aqua.withOpacity(0.8)),
        ],
      ),
    );
  }
}

class StatsSection extends StatelessWidget {
  final DashboardStatsModel? dashboardStats;
  final AdmissionStatsModel? admissionStats;

  const StatsSection({
    super.key,
    this.dashboardStats,
    this.admissionStats,
  });

  @override
  Widget build(BuildContext context) {
    final dailyCompleted = dashboardStats?.dailyProgress.completed ?? 3;
    final dailyGoal = dashboardStats?.dailyProgress.goal ?? 5; 
    final tests = dashboardStats?.dailyProgress.completed ?? 12;
    final duels = 28;
    final wins = 15;
    final accuracy = 92;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (admissionStats != null) ...[
          MobileAdmissionGaugeCard(stats: admissionStats!),
          const SizedBox(height: 24),
        ],

        // Daily Goals Section
        const Text('ЦЕЛИ НА СЕГОДНЯ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.navy, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$dailyCompleted/$dailyGoal тестов пройдено', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B))),
                  Text('${((dailyCompleted / dailyGoal) * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.aqua)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: dailyGoal > 0 ? (dailyCompleted / dailyGoal) : 0.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.aqua),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4 Stat Cards Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildMinimalStatCard('Тесты', '$tests', Icons.quiz_outlined, AppColors.aqua),
            _buildMinimalStatCard('Дуэли', '$duels', Icons.sports_kabaddi_outlined, AppColors.aqua),
            _buildMinimalStatCard('Победы', '$wins', Icons.workspace_premium_outlined, AppColors.gold),
            _buildMinimalStatCard('Точность', '$accuracy%', Icons.gps_fixed_outlined, const Color(0xFF1E293B)),
          ],
        ),

        const SizedBox(height: 24),

        // Leaderboard Section (Бронзовая лига)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('БРОНЗОВАЯ ЛИГА', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.navy, letterSpacing: 0.5)),
            Text('Смотреть', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.navy.withOpacity(0.6))),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              _buildLeaderboardRow(4, 'Ivanov Petr', '1,240 XP', false, isFirst: true),
              _buildLeaderboardRow(5, 'Safarov Behruz', '1,150 XP', true),
              _buildLeaderboardRow(6, 'Kozlova Anna', '1,080 XP', false, isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildMinimalStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, String xp, bool isMe, {bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.vertical(
           top: isFirst ? const Radius.circular(20) : Radius.zero,
           bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 20, child: Text(rank.toString(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isMe ? AppColors.gold : AppColors.navy), textAlign: TextAlign.center)),
          const SizedBox(width: 12),
          CircleAvatar(radius: 14, backgroundColor: isMe ? AppColors.gold.withOpacity(0.4) : const Color(0xFFE2E8F0)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.navy.withOpacity(0.9)))),
          Text(xp, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: isMe ? AppColors.gold : AppColors.navy.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class MobileAdmissionGaugeCard extends StatelessWidget {
  final AdmissionStatsModel stats;

  const MobileAdmissionGaugeCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final probability = stats.admissionProbability;
    
    Color statusColor = AppColors.gold; 
    if (probability > 85) statusColor = AppColors.aqua; 
    if (probability < 40) statusColor = Colors.redAccent;     

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Title + Gauge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ГОТОВНОСТЬ К',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'ПОСТУПЛЕНИЮ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 66,
                height: 66,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Thick background ring
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 6),
                      ),
                    ),
                    // Foreground animated progress indicator
                    SizedBox(
                      width: 66,
                      height: 66,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: probability / 100),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    Text(
                      '${probability.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Info Rows
          _buildInfoRow(Icons.school, 'ВЫБРАННЫЙ УНИВЕРСИТЕТ', stats.targetUniversity ?? stats.universityName),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.architecture, 'СПЕЦИАЛЬНОСТЬ', stats.targetMajorName ?? stats.specialtyName),
          
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),
          const SizedBox(height: 20),
          
          // Score Matrix Section
          const Text('ПРОХОДНЫЕ БАЛЛЫ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildScoreBox('2024', stats.targetPassingScore2024?.toString() ?? '—', const Color(0xFFF8FAFC), const Color(0xFF1E293B)),
              const SizedBox(width: 8),
              _buildScoreBox('2025', stats.targetPassingScore2025?.toString() ?? '—', const Color(0xFFF8FAFC), const Color(0xFF1E293B)),
              const SizedBox(width: 8),
              _buildScoreBox('ЦЕЛЬ', stats.targetPassingScore.toString(), AppColors.gold.withOpacity(0.12), AppColors.gold, isTarget: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBox(String year, String score, Color bgColor, Color textColor, {bool isTarget = false}) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isTarget ? AppColors.gold : const Color(0xFFF1F5F9), width: isTarget ? 1.5 : 1.0),
          boxShadow: isTarget ? [BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 10)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(year.toUpperCase(), style: TextStyle(color: isTarget ? AppColors.gold : const Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(score, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
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

  static const Color _navBg = Color(0xFF2C3545);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double slotWidth = constraints.maxWidth / 5; // 5 Items now
        const double dropWidth = 58;

        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: _navBg,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  // Indicators etc...
                  Row(
                    children: [
                      _buildItem(LucideIcons.layoutDashboard, 'ПАРАМ', 0, slotWidth),
                      _buildItem(LucideIcons.swords, 'ДУЭЛЬ', 1, slotWidth),
                      _buildCenterMenu(slotWidth),
                      _buildItem(LucideIcons.brain, 'ТЕСТЫ', 2, slotWidth),
                      _buildItem(LucideIcons.user, 'ПРОФИЛЬ', 3, slotWidth),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterMenu(double width) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onToggleMenu,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMenuOpen ? AppColors.gold : Colors.white.withOpacity(0.05),
            boxShadow: isMenuOpen ? [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 10)] : null,
          ),
          child: Icon(
            isMenuOpen ? LucideIcons.x : LucideIcons.layoutGrid,
            color: isMenuOpen ? Colors.black : Colors.white60,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index, double width) {
    final bool active = currentIndex == index && !isMenuOpen;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppColors.gold : const Color(0xFFAEB8C8), size: 20),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: active ? AppColors.gold : const Color(0xFFAEB8C8), fontSize: 8, fontWeight: active ? FontWeight.w900 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// SidebarDrawer class has been removed. TopMenuOverlay is now used for navigation.

