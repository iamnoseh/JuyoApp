import 'package:dio/dio.dart';
import 'package:juyo/core/error/failure.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/core/storage/secure_storage_service.dart';
import 'package:juyo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:juyo/features/auth/data/models/session_model.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';
import 'package:juyo/features/auth/domain/entities/password_reset_ticket.dart';
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

      final session = SessionModel.fromAuthResponse(response);
      if (!session.isStudent) {
        await secureStorageService.clearToken();
        return const Error<AuthSession>(
          ForbiddenFailure('Only student accounts can use this app'),
        );
      }

      if (session.isExpired) {
        await secureStorageService.clearToken();
        return const Error<AuthSession>(
          UnauthorizedFailure('Your session has expired'),
        );
      }

      await secureStorageService.saveToken(response.token);
      return Success<AuthSession>(session);
    } on DioException catch (error) {
      return Error<AuthSession>(_mapFailure(error, fallbackMessage: 'Failed to sign in'));
    } catch (_) {
      return const Error<AuthSession>(NetworkFailure('Failed to sign in'));
    }
  }

  @override
  Future<Result<AuthSession>> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String password,
    required String confirmPassword,
    String? referralCode,
  }) async {
    try {
      final response = await remoteDataSource.register(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        password: password,
        confirmPassword: confirmPassword,
        referralCode: referralCode,
      );

      if (response.token.isEmpty) {
        return const Error<AuthSession>(
          UnauthorizedFailure('Token was not returned by the server'),
        );
      }

      final session = SessionModel.fromAuthResponse(response);
      if (!session.isStudent) {
        await secureStorageService.clearToken();
        return const Error<AuthSession>(
          ForbiddenFailure('Only student accounts can use this app'),
        );
      }

      if (session.isExpired) {
        await secureStorageService.clearToken();
        return const Error<AuthSession>(
          UnauthorizedFailure('Your session has expired'),
        );
      }

      await secureStorageService.saveToken(response.token);
      return Success<AuthSession>(session);
    } on DioException catch (error) {
      return Error<AuthSession>(_mapFailure(error, fallbackMessage: 'Failed to register'));
    } catch (_) {
      return const Error<AuthSession>(NetworkFailure('Failed to register'));
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
    if (session.isExpired) {
      await secureStorageService.clearToken();
      return const Error<AuthSession>(
        UnauthorizedFailure('Your session has expired'),
      );
    }

    if (!session.isStudent) {
      await secureStorageService.clearToken();
      return const Error<AuthSession>(
        ForbiddenFailure('Only student accounts can use this app'),
      );
    }

    return Success<AuthSession>(session);
  }

  @override
  Future<Result<String>> sendOtp({
    required String username,
  }) async {
    try {
      final message = await remoteDataSource.sendOtp(username: username);
      return Success<String>(message);
    } on DioException catch (error) {
      return Error<String>(_mapFailure(error, fallbackMessage: 'Failed to send code'));
    } catch (_) {
      return const Error<String>(NetworkFailure('Failed to send code'));
    }
  }

  @override
  Future<Result<PasswordResetTicket>> verifyOtp({
    required String username,
    required String otpCode,
  }) async {
    try {
      final ticket = await remoteDataSource.verifyOtp(
        username: username,
        otpCode: otpCode,
      );

      if (ticket.resetToken.trim().isEmpty) {
        return const Error<PasswordResetTicket>(
          ValidationFailure('Reset token was not returned by the server'),
        );
      }

      return Success<PasswordResetTicket>(ticket);
    } on DioException catch (error) {
      return Error<PasswordResetTicket>(_mapFailure(error, fallbackMessage: 'Failed to verify code'));
    } catch (_) {
      return const Error<PasswordResetTicket>(NetworkFailure('Failed to verify code'));
    }
  }

  @override
  Future<Result<String>> resetPassword({
    required String phoneNumber,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final message = await remoteDataSource.resetPassword(
        phoneNumber: phoneNumber,
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return Success<String>(message);
    } on DioException catch (error) {
      return Error<String>(_mapFailure(error, fallbackMessage: 'Failed to reset password'));
    } catch (_) {
      return const Error<String>(NetworkFailure('Failed to reset password'));
    }
  }

  Failure _mapFailure(
    DioException error, {
    required String fallbackMessage,
  }) {
    final message = _extractMessage(error.response?.data, fallbackMessage);
    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return UnauthorizedFailure(message);
    }

    if (statusCode == 403) {
      return ForbiddenFailure(message);
    }

    if (statusCode == 400 || statusCode == 409 || statusCode == 422) {
      return ValidationFailure(message);
    }

    return NetworkFailure(message);
  }

  String _extractMessage(dynamic data, String fallbackMessage) {
    if (data is Map<String, dynamic>) {
      final directMessage = data['message']?.toString();
      if (directMessage != null && directMessage.trim().isNotEmpty) {
        return directMessage;
      }

      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first?.toString();
        if (firstError != null && firstError.trim().isNotEmpty) {
          return firstError;
        }
      }
    }

    return fallbackMessage;
  }
}
