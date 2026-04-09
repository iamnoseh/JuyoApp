import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/auth/presentation/bloc/password_recovery_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/password_recovery_event.dart';
import 'package:juyo/features/auth/presentation/bloc/password_recovery_state.dart';
import 'package:juyo/features/auth/presentation/widgets/auth_layout.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final PasswordRecoveryBloc _passwordRecoveryBloc;

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordRecoveryBloc = getIt<PasswordRecoveryBloc>();
  }

  @override
  void dispose() {
    _passwordRecoveryBloc.close();
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final l10n = context.l10n;
    final username = _phoneController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authInvalidFields)),
      );
      return;
    }

    _passwordRecoveryBloc.add(PasswordRecoveryOtpRequested(username));
  }

  void _verifyOtp() {
    final l10n = context.l10n;
    final username = _phoneController.text.trim();
    final otpCode = _otpController.text.trim();

    if (username.isEmpty || otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authInvalidFields)),
      );
      return;
    }

    _passwordRecoveryBloc.add(
      PasswordRecoveryOtpVerificationRequested(
        username: username,
        otpCode: otpCode,
      ),
    );
  }

  void _resetPassword(PasswordRecoveryState state) {
    final l10n = context.l10n;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authPasswordMismatch)),
      );
      return;
    }

    final resetToken = state.resetToken;
    if (resetToken == null || resetToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authInvalidFields)),
      );
      return;
    }

    _passwordRecoveryBloc.add(
      PasswordRecoveryResetRequested(
        phoneNumber: _phoneController.text.trim(),
        resetToken: resetToken,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<PasswordRecoveryBloc, PasswordRecoveryState>(
      bloc: _passwordRecoveryBloc,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          _passwordRecoveryBloc.add(const PasswordRecoveryErrorConsumed());
        } else if (state.isCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage ?? l10n.commonSave)),
          );
          context.go(AppRoutes.login);
        }
      },
      builder: (context, state) {
        final title = switch (state.step) {
          1 => l10n.authForgotTitle,
          2 => l10n.authOtpLabel,
          _ => l10n.authResetPassword,
        };
        final subtitle = switch (state.step) {
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
              if (state.step == 1) ...[
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
                  onPressed: state.isLoading ? null : _sendOtp,
                  isLoading: state.isLoading,
                ),
              ],
              if (state.step == 2) ...[
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
                  onPressed: state.isLoading ? null : _verifyOtp,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 12),
                AppSecondaryButton(
                  label: l10n.authResendCode,
                  onPressed: state.isLoading ? null : _sendOtp,
                ),
              ],
              if (state.step == 3) ...[
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
                  onPressed: state.isLoading ? null : () => _resetPassword(state),
                  isLoading: state.isLoading,
                ),
              ],
              const SizedBox(height: 12),
              AppSecondaryButton(
                label: l10n.authBackToLogin,
                onPressed: state.isLoading ? null : () => context.go(AppRoutes.login),
              ),
            ],
          ),
        );
      },
    );
  }
}
