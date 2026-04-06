import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_event.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_state.dart';
import 'package:juyo/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:juyo/features/auth/presentation/pages/login_page.dart';
import 'package:juyo/features/auth/presentation/pages/register_page.dart';
import 'package:juyo/features/home/presentation/pages/dashboard_page.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_event.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const _AppLaunchPage());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DashboardBloc>()..add(const DashboardLoadRequested()),
            child: const DashboardPage(),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const _AppLaunchPage());
    }
  }
}

class _AppLaunchPage extends StatelessWidget {
  const _AppLaunchPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthenticatedState) {
          if (!state.session.isStudent) {
            context.read<AuthBloc>().add(const AuthLoggedOut());
            return const LoginPage();
          }

          return BlocProvider(
            create: (_) => getIt<DashboardBloc>()..add(const DashboardLoadRequested()),
            child: const DashboardPage(),
          );
        }

        return const LoginPage();
      },
    );
  }
}
