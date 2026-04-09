import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/auth/presentation/widgets/auth_layout.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 1;
  bool _loading = false;

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final l10n = context.l10n;
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authInvalidFields)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _step = 2);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final l10n = context.l10n;
    if (_otpController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authInvalidFields)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _step = 3);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = context.l10n;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPasswordMismatch)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset demo is ready. Backend wiring comes later.'),
        ),
      );
      context.go(AppRoutes.login);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (_step) {
      1 => l10n.authForgotTitle,
      2 => l10n.authOtpLabel,
      _ => l10n.authResetPassword,
    };
    final subtitle = switch (_step) {
      1 => l10n.authStepPhone,
      2 => l10n.authStepOtp,
      _ => l10n.authStepReset,
    };

    return AuthLayout(
      title: title,
      subtitle: subtitle,
      canPop: true,
      child: Column(
        children: [
          if (_step == 1) ...[
            AppTextField(
              label: l10n.authPhoneLabel,
              hint: l10n.authPhoneHint,
              prefixIcon: LucideIcons.phone,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            AppPrimaryButton(
              label: l10n.authSendCode,
              onPressed: _loading ? null : _sendOtp,
              isLoading: _loading,
            ),
          ],
          if (_step == 2) ...[
            AppTextField(
              label: l10n.authOtpLabel,
              hint: l10n.authOtpHint,
              prefixIcon: LucideIcons.keyRound,
              controller: _otpController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            AppPrimaryButton(
              label: l10n.authVerifyCode,
              onPressed: _loading ? null : _verifyOtp,
              isLoading: _loading,
            ),
            const SizedBox(height: 12),
            AppSecondaryButton(
              label: l10n.authResendCode,
              onPressed: _loading ? null : _sendOtp,
            ),
          ],
          if (_step == 3) ...[
            AppTextField(
              label: l10n.authPasswordLabel,
              hint: 'password',
              prefixIcon: LucideIcons.lock,
              controller: _newPasswordController,
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
              label: l10n.authResetPassword,
              onPressed: _loading ? null : _resetPassword,
              isLoading: _loading,
            ),
          ],
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
