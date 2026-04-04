import 'package:flutter/material.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/features/auth/presentation/pages/login_page.dart';

void main() {
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
      themeMode: ThemeMode.system, 
      home: const LoginPage(),
    );
  }
}
