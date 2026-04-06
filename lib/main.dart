import 'package:flutter/material.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/features/auth/presentation/pages/login_page.dart';
import 'package:juyo/core/services/auth_service.dart';
import 'package:juyo/features/home/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Auth & Persistence
  await AuthService.init();
  
  runApp(const JuyoApp());
}

class JuyoApp extends StatelessWidget {
  const JuyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juyo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: AuthService.isAuthenticated 
        ? const DashboardPage() 
        : const LoginPage(),
    );
  }
}
