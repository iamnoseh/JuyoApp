import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/auth/presentation/widgets/auth_layout.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/services/auth_service.dart';
import 'package:juyo/features/home/presentation/pages/dashboard_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Вход выполнен успешно!'), backgroundColor: Colors.green),
          );
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Неверное имя пользователя или пароль'), backgroundColor: AppColors.red),
          );
        }
      }
    } catch (e) {
      String errorMessage = 'Ошибка при входе';
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthLayout(
      title: 'Вход',
      child: Column(
        children: [
          JuyoInput(
            label: 'Номер телефона',
            hint: '+992 987 12 34 56',
            icon: LucideIcons.user,
            controller: _usernameController,
            keyboardType: TextInputType.text, // Alphanumeric as requested
          ),
          const SizedBox(height: 24),
          JuyoInput(
            label: 'Пароль',
            hint: '••••••••',
            icon: LucideIcons.lock,
            controller: _passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
              },
              child: const Text(
                'Забыли пароль?',
                style: TextStyle(color: AppColors.aqua, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 32),
          JuyoButton(
            text: 'Войти',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Нет аккаунта?",
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                },
                child: const Text(
                  'Регистрация',
                  style: TextStyle(color: AppColors.aqua, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
