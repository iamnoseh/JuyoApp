import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/app/router/app_router.dart';
import 'package:juyo/core/l10n/locale_controller.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/theme/theme_mode_controller.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/l10n/app_localizations.dart';

class JuyoApp extends StatelessWidget {
  const JuyoApp({super.key});

  static const _supportedLocales = [
    Locale('ru'),
    Locale('en'),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: getIt<AuthBloc>(),
        ),
      ],
      child: AnimatedBuilder(
        animation: Listenable.merge([
          getIt<ThemeModeController>(),
          getIt<LocaleController>(),
        ]),
        builder: (context, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'JUYO',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: getIt<ThemeModeController>().themeMode,
          locale: getIt<LocaleController>().locale,
          routerConfig: AppRouter.router,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) {
              return const Locale('ru');
            }
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return const Locale('ru');
          },
          supportedLocales: _supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
  }
}
