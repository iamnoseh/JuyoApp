import 'package:dio/dio.dart';
import 'package:juyo/core/error/failure.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/core/storage/secure_storage_service.dart';
import 'package:juyo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:juyo/features/auth/data/models/session_model.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';
import 'package:juyo/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorageService;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorageService,
  });

  @override
  Future<Result<AuthSession>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        username: username,
        password: password,
      );

      if (response.token.isEmpty) {
        return const Error<AuthSession>(
          UnauthorizedFailure('Token was not returned by the server'),
        );
      }

      final session = SessionModel.fromToken(response.token);
      if (!session.isStudent) {
        await secureStorageService.clearToken();
        return const Error<AuthSession>(
          ForbiddenFailure('Only student accounts can use this app'),
        );
      }

      await secureStorageService.saveToken(response.token);
      return Success<AuthSession>(session);
    } on DioException catch (error) {
      final response = error.response?.data;
      final message = response is Map<String, dynamic> && response['message'] is String
          ? response['message'] as String
          : 'Failed to sign in';

      if (error.response?.statusCode == 401) {
        return Error<AuthSession>(UnauthorizedFailure(message));
      }

      if (error.response?.statusCode == 400 || error.response?.statusCode == 422) {
        return Error<AuthSession>(ValidationFailure(message));
      }

      return Error<AuthSession>(NetworkFailure(message));
    } catch (_) {
      return const Error<AuthSession>(NetworkFailure('Failed to sign in'));
    }
  }

  @override
  Future<void> logout() async {
    await secureStorageService.clearToken();
  }

  @override
  Future<Result<AuthSession>> restoreSession() async {
    final token = await secureStorageService.readToken();

    if (token == null || token.isEmpty) {
      return const Error<AuthSession>(
        UnauthorizedFailure('No saved session'),
      );
    }

    final session = SessionModel.fromToken(token);
    if (!session.isStudent) {
      await secureStorageService.clearToken();
      return const Error<AuthSession>(
        ForbiddenFailure('Only student accounts can use this app'),
      );
    }

    return Success<AuthSession>(session);
  }
}
