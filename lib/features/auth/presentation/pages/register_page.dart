import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/auth/presentation/widgets/auth_layout.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/network/api_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_firstNameController.text.isEmpty || 
        _lastNameController.text.isEmpty || 
        _phoneController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля'), backgroundColor: AppColors.red),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароли не совпадают'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.dio.post('/Auth/register', data: {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneController.text,
        'referralCode': _referralController.text.isEmpty ? null : _referralController.text,
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Регистрация прошла успешно! Теперь вы можете войти.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back to Login
      }
    } on DioException catch (e) {
      if (!mounted) return;
      String errorMessage = 'Ошибка при регистрации';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthLayout(
      title: 'Регистрация',
      child: Column(
        children: [
          JuyoInput(
            label: 'Имя',
            hint: 'Алишер',
            icon: LucideIcons.user,
            controller: _firstNameController,
          ),
          const SizedBox(height: 16),
          JuyoInput(
            label: 'Фамилия',
            hint: 'Сафаров',
            icon: LucideIcons.user,
            controller: _lastNameController,
          ),
          const SizedBox(height: 16),
          JuyoInput(
            label: 'Номер телефона',
            hint: '+992 000 00 00 00',
            icon: LucideIcons.phone,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          JuyoInput(
            label: 'Реферальный код (опционально)',
            hint: 'REF-123',
            icon: LucideIcons.gift,
            controller: _referralController,
          ),
          const SizedBox(height: 16),
          JuyoInput(
            label: 'Пароль',
            hint: '••••••••',
            icon: LucideIcons.lock,
            isPassword: true,
            controller: _passwordController,
          ),
          const SizedBox(height: 16),
          JuyoInput(
            label: 'Подтвердите пароль',
            hint: '••••••••',
            icon: LucideIcons.checkCircle,
            isPassword: true,
            controller: _confirmPasswordController,
          ),
          const SizedBox(height: 32),
          JuyoButton(
            text: 'Зарегистрироваться',
            isLoading: _isLoading,
            onPressed: _handleRegister,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Уже есть аккаунт?',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Войти',
                  style: TextStyle(color: AppColors.aqua, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
