import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/widgets/app_ui.dart';
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
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration demo is ready. API connection comes later.'),
        ),
      );
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
            hint: 'password',
            prefixIcon: LucideIcons.lock,
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authConfirmPasswordLabel,
            hint: 'password',
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
          const SizedBox(height: 12),
          AppSecondaryButton(
            label: l10n.authBackToLogin,
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}
