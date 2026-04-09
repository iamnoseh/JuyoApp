import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/storage/secure_storage_service.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_event.dart';
import 'package:juyo/features/auth/presentation/widgets/auth_layout.dart';

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

  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _referralController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authInvalidFields)),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPasswordMismatch)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await ApiClient.dio.post('/Auth/register', data: {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'referralCode': _referralController.text.trim().isEmpty
            ? null
            : _referralController.text.trim(),
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
      });

      final raw = response.data is Map ? response.data['data'] ?? response.data : null;
      final token = raw is Map ? raw['token']?.toString() ?? '' : '';
      if (token.isNotEmpty) {
        await getIt<SecureStorageService>().saveToken(token);
        getIt<AuthBloc>().add(const AuthAppStarted());
      }
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } on DioException catch (error) {
      if (!mounted) return;
      final message = error.response?.data is Map
          ? (error.response?.data['message']?.toString() ?? l10n.errorTitle)
          : (error.message ?? l10n.errorTitle);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AuthLayout(
      title: l10n.authRegisterTitle,
      subtitle: l10n.authRegisterSubtitle,
      canPop: true,
      child: Column(
        children: [
          AppTextField(
            label: l10n.authFirstNameLabel,
            hint: 'Ali',
            prefixIcon: LucideIcons.user,
            controller: _firstNameController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authLastNameLabel,
            hint: 'Safarov',
            prefixIcon: LucideIcons.userCircle,
            controller: _lastNameController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authPhoneLabel,
            hint: l10n.authPhoneHint,
            prefixIcon: LucideIcons.phone,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authReferralCodeLabel,
            hint: 'REF-123',
            prefixIcon: LucideIcons.gift,
            controller: _referralController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authPasswordLabel,
            hint: '••••••••',
            prefixIcon: LucideIcons.lock,
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authConfirmPasswordLabel,
            hint: '••••••••',
            prefixIcon: LucideIcons.checkCircle,
            controller: _confirmPasswordController,
            obscureText: true,
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            label: l10n.authSignUp,
            onPressed: _loading ? null : _submit,
            isLoading: _loading,
          ),
        ],
      ),
    );
  }
}
