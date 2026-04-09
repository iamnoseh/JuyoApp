import 'package:flutter/material.dart';
import 'package:juyo/app/app.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/core/storage/secure_storage_service.dart';
import 'package:juyo/core/services/auth_service.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_event.dart';

Future<void> bootstrap() async {
  await AuthService.init();
  await setupServiceLocator();
  final secureStorage = getIt<SecureStorageService>();
  final secureToken = await secureStorage.readToken();
  final legacyToken = AuthService.token;
  if ((secureToken == null || secureToken.isEmpty) &&
      legacyToken != null &&
      legacyToken.isNotEmpty) {
    await secureStorage.saveToken(legacyToken);
  }
  getIt<AuthBloc>().add(const AuthAppStarted());
  runApp(const JuyoApp());
}
