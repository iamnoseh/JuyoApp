import 'package:dio/dio.dart';
import 'package:juyo/core/error/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final message = _resolveMessage(err);

    if (statusCode == 401) {
      handler.reject(
        err.copyWith(error: UnauthorizedException(message)),
      );
      return;
    }

    if (statusCode == 400 || statusCode == 422) {
      handler.reject(
        err.copyWith(error: ValidationException(message)),
      );
      return;
    }

    handler.reject(
      err.copyWith(error: NetworkException(message)),
    );
  }

  String _resolveMessage(DioException err) {
    final response = err.response?.data;
    if (response is Map<String, dynamic>) {
      final message = response['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return err.message ?? 'Network error';
  }
}
