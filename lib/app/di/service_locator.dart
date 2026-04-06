import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:juyo/core/network/dio_factory.dart';
import 'package:juyo/core/storage/local_storage_service.dart';
import 'package:juyo/core/storage/secure_storage_service.dart';
import 'package:juyo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:juyo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:juyo/features/auth/domain/repositories/auth_repository.dart';
import 'package:juyo/features/auth/domain/usecases/login_use_case.dart';
import 'package:juyo/features/auth/domain/usecases/logout_use_case.dart';
import 'package:juyo/features/auth/domain/usecases/restore_session_use_case.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
  }

  if (!getIt.isRegistered<LocalStorageService>()) {
    final localStorage = await LocalStorageService.create();
    getIt.registerLazySingleton<LocalStorageService>(() => localStorage);
  }

  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(
      () => DioFactory.create(
        secureStorageService: getIt<SecureStorageService>(),
      ),
    );
  }

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<Dio>()),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        secureStorageService: getIt<SecureStorageService>(),
      ),
    );
  }

  if (!getIt.isRegistered<LoginUseCase>()) {
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<LogoutUseCase>()) {
    getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<RestoreSessionUseCase>()) {
    getIt.registerLazySingleton<RestoreSessionUseCase>(
      () => RestoreSessionUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUseCase: getIt<LoginUseCase>(),
        restoreSessionUseCase: getIt<RestoreSessionUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
      ),
    );
  }
}
