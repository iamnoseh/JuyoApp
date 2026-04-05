import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/auth/presentation/pages/login_page.dart';
import 'package:juyo/core/services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const SidebarDrawer(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16, 0, 16,
          16 + MediaQuery.of(context).padding.bottom, // Clears home indicator
        ),
        child: JuyoBottomDock(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCurvedHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const WelcomeCard(),
                  const SizedBox(height: 18),
                  const StatsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedHeader() {
    return Stack(
      children: [
        Container(
          height: 140,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60),
            ),
            image: DecorationImage(
              image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.1,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.menu, color: Colors.white, size: 28),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
      ],
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
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Привет,\nАлишер!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.1, color: AppColors.navy)),
                  const SizedBox(height: 8),
                  const Text('«Ман танҳо як чиз медонам...»', style: TextStyle(color: Colors.black45, fontSize: 11, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  SizedBox(height: 40, child: JuyoButton(text: 'Обучение', onPressed: () {})),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Icon(LucideIcons.brain, size: 54, color: AppColors.aqua.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('АКТИВНОСТЬ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [_buildPill('30д', true), _buildPill('90д', false)]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard('Тесты', '45', LucideIcons.checkCircle, AppColors.aqua),
            _buildStatCard('Дуэли', '12', LucideIcons.swords, Colors.orange),
            _buildStatCard('Победы', '9', LucideIcons.trophy, AppColors.gold),
            _buildStatCard('Точность', '88%', LucideIcons.target, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildPill(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : null,
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: active ? Colors.black : Colors.black38)),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 18),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }
}

class JuyoBottomDock extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const JuyoBottomDock({super.key, required this.currentIndex, required this.onTap});

  static const Color _navBg = Color(0xFF2C3545);
  static const Color _activeColor = Color(0xFF5DBCCF);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double slotWidth = totalWidth / 4;
        const double dropWidth = 64;
        final double leftOffset =
            (slotWidth * currentIndex) + (slotWidth - dropWidth) / 2;

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
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Sliding active highlight capsule
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    left: leftOffset,
                    top: (66 - 48) / 2,
                    child: Container(
                      width: dropWidth,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  // Icon row on top
                  Row(
                    children: [
                      _buildItem(LucideIcons.layoutGrid, 'ПАНЕЛЬ', 0),
                      _buildItem(LucideIcons.swords, 'ДУЭЛЬ', 1),
                      _buildItem(LucideIcons.brain, 'ТЕСТЫ', 2),
                      _buildItem(LucideIcons.user, 'ПРОФИЛЬ', 3),
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

  Widget _buildItem(IconData icon, String label, int index) {
    final bool active = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? AppColors.gold : const Color(0xFFAEB8C8),
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.gold : const Color(0xFFAEB8C8),
                fontSize: 9,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navy.withOpacity(0.92),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            child: Column(
              children: [
                // Profile Hero Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.aqua, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://i.pravatar.cc/150?u=alisher'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Алишер Назаров',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white12, indent: 24, endIndent: 24),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: [
                      _buildMenuItem(LucideIcons.layoutDashboard, 'Панель управления', true),
                      _buildMenuItem(LucideIcons.swords, 'Дуэль', false),
                      _buildMenuItem(LucideIcons.brain, 'Тесты', false),
                      _buildMenuItem(LucideIcons.flame, 'Красный Список', false, isLocked: true),
                      _buildMenuItem(LucideIcons.barChart3, 'Рейтинг лиги', false),
                      _buildMenuItem(LucideIcons.school, 'Рейтинг школ', false),
                      _buildMenuItem(LucideIcons.crown, 'Premium Juyo', false, isPremium: true),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: JuyoButton(
                    text: 'Выйти',
                    isSecondary: true,
                    onPressed: () async {
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool active, {bool isLocked = false, bool isPremium = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: active ? LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.04),
            ],
          ) : null,
          border: active ? Border.all(color: Colors.white.withOpacity(0.1), width: 1) : null,
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Icon(
            icon, 
            color: active ? AppColors.aqua : (isPremium ? AppColors.gold : Colors.white60), 
            size: 22
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: active ? Colors.white : Colors.white60, 
              fontWeight: active ? FontWeight.w900 : FontWeight.bold
            ),
          ),
          trailing: isLocked 
            ? const Icon(LucideIcons.lock, size: 14, color: Colors.white24) 
            : (active ? Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.aqua, shape: BoxShape.circle)) : null),
          onTap: () {},
        ),
      ),
    );
  }
}
