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
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isMenuOpen = false;
  UserModel? _user;
  String _motivation = 'Загрузка...';
  DashboardStatsModel? _dashboardStats;
  AdmissionStatsModel? _admissionStats;
  List<LeagueLeaderboardModel> _leaderboard = [];
  List<SkillProgressModel> _skills = [];

  Future<void> _refresh() async {
    context.read<DashboardBloc>().add(const DashboardRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardLoading) _isLoading = true;
        if (state is DashboardLoaded) {
          _user = state.data.user;
          _motivation = state.data.motivation;
          _dashboardStats = state.data.dashboardStats;
          _admissionStats = state.data.admissionStats;
          _leaderboard = state.data.leaderboard;
          _skills = state.data.skills;
          _isLoading = false;
        }
        if (state is DashboardFailure) {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.red));
        }
        setState(() {});
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final topInset = _topHeight + 24;
    final bottomInset = MediaQuery.of(context).padding.bottom + _dockHeight + 28;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.aqua)));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: JuyoBottomDock(
          currentIndex: _selectedIndex,
          isMenuOpen: _isMenuOpen,
          onToggleMenu: () => setState(() => _isMenuOpen = !_isMenuOpen),
          onTap: (i) => setState(() {
            _selectedIndex = i;
            _isMenuOpen = false;
          }),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: (_selectedIndex == 3) ? 1 : 0,
              children: [
                RefreshIndicator(
                  onRefresh: _refresh,
                  edgeOffset: topInset,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, bottomInset),
                    children: [
                      _welcomeCard(),
                      const SizedBox(height: 12),
                      _statsCard(),
                      const SizedBox(height: 12),
                      _admissionCard(),
                      const SizedBox(height: 12),
                      _leaderboardCard(),
                    ],
                  ),
                ),
                ProfilePage(
                  user: _user,
                  skills: _skills,
                  onRefresh: _refresh,
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
            duration: const Duration(milliseconds: 400),
            top: _isMenuOpen ? 0 : -MediaQuery.of(context).size.height * 0.55,
            left: 0,
            right: 0,
            child: _topMenu(),
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

  Widget _welcomeCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Привет, ${_user?.fullName.split(' ').first ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('$_motivation', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.slate)),
            ]),
          ),
          const Icon(LucideIcons.brain, color: AppColors.aqua),
        ]),
      );

  Widget _statsCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          _miniStat('Тесты', '${_dashboardStats?.dailyProgress.completed ?? 0}'),
          _miniStat('XP', '${_user?.xp ?? 0}'),
          _miniStat('Рейтинг', '${_user?.eloRating ?? 0}'),
        ]),
      );

  Widget _admissionCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Готовность к поступлению', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(_admissionStats?.targetUniversity ?? _admissionStats?.universityName ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(_admissionStats?.targetMajorName ?? _admissionStats?.specialtyName ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.slate)),
        ]),
      );

  Widget _leaderboardCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: _leaderboard.isEmpty
              ? [const Text('Нет данных', style: TextStyle(fontSize: 12, color: AppColors.slate))]
              : _leaderboard.take(6).map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      SizedBox(width: 24, child: Text('${e.rank}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                      Expanded(child: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))),
                      Text(e.xp, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ]),
                  )).toList(),
        ),
      );

  Widget _miniStat(String title, String value) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(color: AppColors.milkyCard, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.slate)),
          ]),
        ),
      );

  Widget _topMenu() => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: const Color(0xFF343F51).withValues(alpha: 0.98),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(children: [
              const Text('JUYO MENU', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _menuItem(LucideIcons.listTodo, 'Красный список'),
              _menuItem(LucideIcons.trophy, 'Рейтинг лиги'),
              _menuItem(LucideIcons.building2, 'Рейтинг школ'),
              const Spacer(),
              SizedBox(
                height: 44,
                child: JuyoButton(
                  text: 'Выйти',
                  isDanger: true,
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLoggedOut());
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                  },
                ),
              ),
            ]),
          ),
        ),
      );

  Widget _menuItem(IconData icon, String title) => ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        leading: Icon(icon, size: 16, color: Colors.white70),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        onTap: () {},
      );
}

class JuyoBottomDock extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;
  const JuyoBottomDock({super.key, required this.currentIndex, required this.onTap, required this.isMenuOpen, required this.onToggleMenu});

  @override
  Widget build(BuildContext context) {
    final slot = (MediaQuery.of(context).size.width - 32) / 5;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 66,
          decoration: BoxDecoration(color: const Color(0xFF2C3545), borderRadius: BorderRadius.circular(28)),
          child: Row(children: [
            _item(slot, LucideIcons.layoutDashboard, 'ПАРАМ', 0),
            _item(slot, LucideIcons.swords, 'ДУЭЛЬ', 1),
            SizedBox(width: slot, child: GestureDetector(onTap: onToggleMenu, child: Icon(isMenuOpen ? LucideIcons.x : LucideIcons.layoutGrid, color: AppColors.gold, size: 22))),
            _item(slot, LucideIcons.brain, 'ТЕСТЫ', 2),
            _item(slot, LucideIcons.user, 'ПРОФИЛЬ', 3),
          ]),
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: active ? AppColors.gold : const Color(0xFFAEB8C8)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 8, color: active ? AppColors.gold : const Color(0xFFAEB8C8))),
        ]),
      ),
    );
  }
}
