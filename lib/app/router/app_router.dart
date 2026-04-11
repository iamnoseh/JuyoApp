import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_routes.dart';
import 'package:juyo/app/router/go_router_refresh_stream.dart';
import 'package:juyo/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:juyo/features/auth/presentation/pages/auth_splash_page.dart';
import 'package:juyo/features/auth/presentation/pages/login_page.dart';
import 'package:juyo/features/auth/presentation/pages/register_page.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_state.dart';
import 'package:juyo/features/duel/presentation/pages/duel_hub_page.dart';
import 'package:juyo/features/duel/presentation/pages/duel_invite_page.dart';
import 'package:juyo/features/home/presentation/pages/dashboard_overview_page.dart';
import 'package:juyo/features/league/presentation/pages/league_page.dart';
import 'package:juyo/features/premium/presentation/pages/premium_page.dart';
import 'package:juyo/features/profile/presentation/pages/profile_edit_route_page.dart';
import 'package:juyo/features/profile/presentation/pages/profile_route_page.dart';
import 'package:juyo/features/red_list/presentation/pages/red_list_page.dart';
import 'package:juyo/features/referral/presentation/pages/referral_page.dart';
import 'package:juyo/features/school/presentation/pages/school_leaderboard_page.dart';
import 'package:juyo/features/shell/presentation/pages/app_shell_page.dart';
import 'package:juyo/features/tests/presentation/pages/exam_page.dart';
import 'package:juyo/features/tests/presentation/pages/practice_clusters_page.dart';
import 'package:juyo/features/tests/presentation/pages/subject_tests_page.dart';
import 'package:juyo/features/tests/presentation/pages/test_result_page.dart';
import 'package:juyo/features/tests/presentation/pages/test_runner_page.dart';
import 'package:juyo/features/tests/presentation/pages/tests_home_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
    redirect: (context, state) {
      final path = state.matchedLocation;
      final authState = getIt<AuthBloc>().state;

      final isAuthRoute = path == AppRoutes.login ||
          path == AppRoutes.register ||
          path == AppRoutes.forgotPassword;
      final isPublicRoute = path == AppRoutes.splash || path.startsWith(AppRoutes.duelInvite);
      final isProtectedRoute = !isAuthRoute && !isPublicRoute;

      if (authState is AuthInitial || authState is AuthLoading) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (authState is AuthenticatedState) {
        if (path == AppRoutes.splash || isAuthRoute) {
          return AppRoutes.dashboard;
        }
        return null;
      }

      if (isProtectedRoute) {
        return AppRoutes.login;
      }

      if (path == AppRoutes.splash || path == AppRoutes.landing) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const AuthSplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '${AppRoutes.duelInvite}/:inviteCode',
        builder: (context, state) => DuelInvitePage(
          inviteCode: state.pathParameters['inviteCode'] ?? '',
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellPage(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardOverviewPage(),
          ),
          GoRoute(
            path: AppRoutes.duel,
            builder: (context, state) => const DuelHubPage(),
          ),
          GoRoute(
            path: AppRoutes.tests,
            builder: (context, state) => const TestsHomePage(),
          ),
          GoRoute(
            path: AppRoutes.subjectTests,
            builder: (context, state) => const SubjectTestsPage(),
          ),
          GoRoute(
            path: AppRoutes.league,
            builder: (context, state) => const LeagueStudentPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileRoutePage(),
          ),
          GoRoute(
            path: AppRoutes.profileEdit,
            builder: (context, state) => const ProfileEditRoutePage(),
          ),
          GoRoute(
            path: AppRoutes.practice,
            builder: (context, state) => const PracticeClustersPage(),
          ),
          GoRoute(
            path: AppRoutes.premium,
            builder: (context, state) => const PremiumStudentPage(),
          ),
          GoRoute(
            path: AppRoutes.referral,
            builder: (context, state) => const ReferralStudentPage(),
          ),
          GoRoute(
            path: AppRoutes.redList,
            builder: (context, state) => const RedListStudentPage(),
          ),
          GoRoute(
            path: AppRoutes.schoolLeaderboard,
            builder: (context, state) => const SchoolLeaderboardPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.exam,
        builder: (context, state) => const ExamSessionPage(),
      ),
      GoRoute(
        path: '${AppRoutes.testRunner}/:sessionId',
        builder: (context, state) => TestRunnerPage(
          sessionId: state.pathParameters['sessionId'] ?? '',
        ),
      ),
      GoRoute(
        path: '${AppRoutes.testResult}/:sessionId',
        builder: (context, state) => TestResultPage(
          sessionId: state.pathParameters['sessionId'] ?? '',
        ),
      ),
    ],
  );
}
