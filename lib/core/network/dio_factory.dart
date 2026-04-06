import 'package:dio/dio.dart';
import 'package:juyo/core/constants/app_constants.dart';
import 'package:juyo/core/network/interceptors/auth_interceptor.dart';
import 'package:juyo/core/network/interceptors/error_interceptor.dart';
import 'package:juyo/core/storage/secure_storage_service.dart';

class DioFactory {
  static Dio create({
    required SecureStorageService secureStorageService,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(secureStorageService),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
