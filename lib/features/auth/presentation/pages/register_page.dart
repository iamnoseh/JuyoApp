import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_event.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_state.dart';
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

    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            phoneNumber: _phoneController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            referralCode: _referralController.text.trim().isEmpty
                ? null
                : _referralController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final initialReferralCode = GoRouterState.of(context).uri.queryParameters['ref'];
    if (initialReferralCode != null &&
        initialReferralCode.trim().isNotEmpty &&
        _referralController.text.trim().isEmpty) {
      _referralController.text = initialReferralCode.trim();
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthRegisterInProgress;

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
                onPressed: isLoading ? null : _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              AppSecondaryButton(
                label: l10n.authBackToLogin,
                onPressed: isLoading ? null : () => context.go(AppRoutes.login),
              ),
            ],
          ),
        );
      },
    );
  }
}
