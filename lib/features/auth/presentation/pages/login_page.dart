import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_event.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_state.dart';
import 'package:juyo/features/auth/presentation/widgets/auth_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    if (_phoneController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authInvalidFields)),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            username: _phoneController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is AuthenticatedState && mounted) {
          context.go(AppRoutes.dashboard);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoginInProgress;

        return AuthLayout(
          title: l10n.authLoginTitle,
          subtitle: l10n.authLoginSubtitle,
          child: Column(
            children: [
              AppTextField(
                label: l10n.authPhoneLabel,
                hint: l10n.authPhoneHint,
                prefixIcon: LucideIcons.phone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.authPasswordLabel,
                hint: '••••••••',
                prefixIcon: LucideIcons.lock,
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: Text(
                    l10n.authForgotPassword,
                    style: const TextStyle(color: AppColors.aqua),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AppPrimaryButton(
                label: l10n.authSignIn,
                onPressed: isLoading ? null : _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              AppSecondaryButton(
                label: l10n.authSignUp,
                onPressed: () => context.push(AppRoutes.register),
              ),
            ],
          ),
        );
      },
    );
  }
}
