import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/auth/presentation/pages/login_page.dart';

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildCurvedHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 110), // Space for slim dock
                  child: Column(
                    children: [
                      const WelcomeCard(),
                      const SizedBox(height: 24),
                      const StatsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Ultra-Premium Slim Glass Dock (Pixel-Perfect Alignment)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: JuyoBottomDock(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurvedHeader() {
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(80),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
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
      offset: const Offset(0, -30),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 15)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Привет,\nАлишер!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1, color: AppColors.navy)),
                  const SizedBox(height: 12),
                  const Text('«Ман танҳо як чиз медонам...»', style: TextStyle(color: Colors.black45, fontSize: 13, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 20),
                  SizedBox(height: 48, child: JuyoButton(text: 'Обучение', onPressed: () {})),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Icon(LucideIcons.brain, size: 80, color: AppColors.aqua.withOpacity(0.8)),
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
            const Text('АКТИВНОСТЬ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [_buildPill('30д', true), _buildPill('90д', false)]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : null,
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: active ? Colors.black : Colors.black38)),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        double slotWidth = totalWidth / 4;
        double dropWidth = 64;
        double leftOffset = (slotWidth * currentIndex) + (slotWidth - dropWidth) / 2;

        return ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 64, // Slimmer height as requested
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.85),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Stack(
                children: [
                  // Pixel-Perfect Sliding 'Glass Drop' (behind icons)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    left: leftOffset,
                    top: (64 - 48) / 2, // Center vertically
                    child: Container(
                      width: dropWidth,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.35), // Brighter Shine (Дурухш)
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35), // Reflective Specular Border
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildDockItem(LucideIcons.layoutGrid, 'ПАНЕЛЬ', 0),
                      _buildDockItem(LucideIcons.swords, 'ДУЭЛЬ', 1),
                      _buildDockItem(LucideIcons.brain, 'ТЕСТЫ', 2),
                      _buildDockItem(LucideIcons.user, 'ПРОФИЛЬ', 3),
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

  Widget _buildDockItem(IconData icon, String label, int index) {
    bool active = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active ? AppColors.aqua : Colors.white60,
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white60,
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w900 : FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.navy.withOpacity(0.85),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
                child: Center(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4.0),
                      children: [
                        TextSpan(text: 'J', style: TextStyle(color: AppColors.gold)),
                        TextSpan(text: 'UYO', style: TextStyle(color: AppColors.aqua)),
                      ],
                    ),
                  ),
                ),
              ),
              _buildMenuItem(LucideIcons.layoutDashboard, 'Панель управления', true),
              _buildMenuItem(LucideIcons.swords, 'Дуэль', false),
              _buildMenuItem(LucideIcons.brain, 'Тесты', false),
              _buildMenuItem(LucideIcons.flame, 'Красный Список', false, isLocked: true),
              _buildMenuItem(LucideIcons.barChart3, 'Рейтинг лиги', false),
              _buildMenuItem(LucideIcons.school, 'Рейтинг школ', false),
              _buildMenuItem(LucideIcons.gift, 'Пригласить друга', false),
              _buildMenuItem(LucideIcons.crown, 'Premium', false, isPremium: true),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: JuyoButton(
                  text: 'Выйти',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
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

  Widget _buildMenuItem(IconData icon, String title, bool active, {bool isLocked = false, bool isPremium = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListTile(
            tileColor: active ? Colors.white.withOpacity(0.1) : Colors.transparent,
            leading: Icon(icon, color: active ? AppColors.aqua : (isPremium ? AppColors.gold : Colors.white60)),
            title: Text(
              title,
              style: TextStyle(color: active ? Colors.white : Colors.white60, fontWeight: active ? FontWeight.bold : FontWeight.normal),
            ),
            trailing: isLocked ? const Icon(LucideIcons.lock, size: 16, color: Colors.white24) : null,
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
