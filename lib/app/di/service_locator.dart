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
import 'package:juyo/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:juyo/features/home/domain/repositories/dashboard_repository.dart';
import 'package:juyo/features/home/domain/usecases/get_dashboard_data_use_case.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:juyo/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:juyo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:juyo/features/profile/domain/repositories/profile_repository.dart';
import 'package:juyo/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:juyo/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:juyo/features/reference/data/datasources/reference_remote_data_source.dart';
import 'package:juyo/features/reference/data/repositories/reference_repository_impl.dart';
import 'package:juyo/features/reference/domain/repositories/reference_repository.dart';
import 'package:juyo/features/reference/domain/usecases/get_majors_use_case.dart';
import 'package:juyo/features/reference/domain/usecases/get_schools_use_case.dart';
import 'package:juyo/features/reference/domain/usecases/get_universities_use_case.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_bloc.dart';

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

  if (!getIt.isRegistered<DashboardRepository>()) {
    getIt.registerLazySingleton<DashboardRepository>(
      DashboardRepositoryImpl.new,
    );
  }

  if (!getIt.isRegistered<GetDashboardDataUseCase>()) {
    getIt.registerLazySingleton<GetDashboardDataUseCase>(
      () => GetDashboardDataUseCase(getIt<DashboardRepository>()),
    );
  }

  if (!getIt.isRegistered<DashboardBloc>()) {
    getIt.registerFactory<DashboardBloc>(
      () => DashboardBloc(
        getDashboardDataUseCase: getIt<GetDashboardDataUseCase>(),
      ),
    );
  }

  if (!getIt.isRegistered<ProfileRemoteDataSource>()) {
    getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(getIt<Dio>()),
    );
  }

  if (!getIt.isRegistered<ProfileRepository>()) {
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: getIt<ProfileRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetProfileUseCase>()) {
    getIt.registerLazySingleton<GetProfileUseCase>(
      () => GetProfileUseCase(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<UpdateProfileUseCase>()) {
    getIt.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<ProfileBloc>()) {
    getIt.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getProfileUseCase: getIt<GetProfileUseCase>(),
        updateProfileUseCase: getIt<UpdateProfileUseCase>(),
      ),
    );
  }

  if (!getIt.isRegistered<ReferenceRemoteDataSource>()) {
    getIt.registerLazySingleton<ReferenceRemoteDataSource>(
      () => ReferenceRemoteDataSource(getIt<Dio>()),
    );
  }

  if (!getIt.isRegistered<ReferenceRepository>()) {
    getIt.registerLazySingleton<ReferenceRepository>(
      () => ReferenceRepositoryImpl(
        remoteDataSource: getIt<ReferenceRemoteDataSource>(),
      ),
    );
  }

  if (!getIt.isRegistered<GetSchoolsUseCase>()) {
    getIt.registerLazySingleton<GetSchoolsUseCase>(
      () => GetSchoolsUseCase(getIt<ReferenceRepository>()),
    );
  }

  if (!getIt.isRegistered<GetUniversitiesUseCase>()) {
    getIt.registerLazySingleton<GetUniversitiesUseCase>(
      () => GetUniversitiesUseCase(getIt<ReferenceRepository>()),
    );
  }

  if (!getIt.isRegistered<GetMajorsUseCase>()) {
    getIt.registerLazySingleton<GetMajorsUseCase>(
      () => GetMajorsUseCase(getIt<ReferenceRepository>()),
    );
  }

  if (!getIt.isRegistered<ReferenceBloc>()) {
    getIt.registerFactory<ReferenceBloc>(
      () => ReferenceBloc(
        getSchoolsUseCase: getIt<GetSchoolsUseCase>(),
        getUniversitiesUseCase: getIt<GetUniversitiesUseCase>(),
        getMajorsUseCase: getIt<GetMajorsUseCase>(),
      ),
    );
  }
}
