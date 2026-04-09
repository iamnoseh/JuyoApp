import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_router.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/theme/theme_mode_controller.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/l10n/app_localizations.dart';

class JuyoApp extends StatelessWidget {
  const JuyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: getIt<AuthBloc>(),
        ),
      ],
      child: AnimatedBuilder(
        animation: getIt<ThemeModeController>(),
        builder: (context, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Juyo',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: getIt<ThemeModeController>().themeMode,
          routerConfig: AppRouter.router,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) {
              return const Locale('tg');
            }
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return const Locale('tg');
          },
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
  }
}
