import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/auth/presentation/widgets/auth_layout.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/network/api_client.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int step = 1;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите номер телефона'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.post('/Auth/send-otp', data: {
        'phoneNumber': _phoneController.text,
      });

      if (response.statusCode == 200) {
        setState(() => step = 2);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Код отправлен!'), backgroundColor: Colors.green),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Ошибка при отправке кода';
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
    String title = 'Забыли?';
    if (step == 2) title = 'Код';
    if (step == 3) title = 'Сброс';

    return AuthLayout(
      title: title,
      child: Column(
        children: [
          if (step == 1) ...[
            JuyoInput(
              label: 'Номер телефона',
              hint: '+992 000 00 00 00',
              icon: LucideIcons.phone,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            JuyoButton(
              text: 'Получить код',
              isLoading: _isLoading,
              onPressed: _handleSendOtp,
            ),
          ] else if (step == 2) ...[
            JuyoInput(
              label: 'Код подтверждения',
              hint: '0 0 0 0',
              icon: LucideIcons.checkCircle,
              controller: _otpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            JuyoButton(
              text: 'Подтвердить',
              onPressed: () => setState(() => step = 3),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _handleSendOtp,
              child: const Text(
                'Отправить еще раз',
                style: TextStyle(color: AppColors.aqua, fontWeight: FontWeight.w700),
              ),
            ),
          ] else if (step == 3) ...[
            JuyoInput(
              label: 'Новый пароль',
              hint: '••••••••',
              icon: LucideIcons.lock,
              isPassword: true,
              controller: _newPasswordController,
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
              text: 'Сбросить пароль',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Назад ко входу',
              style: TextStyle(color: AppColors.slate, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
