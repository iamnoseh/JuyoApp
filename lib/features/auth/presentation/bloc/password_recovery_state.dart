import 'package:equatable/equatable.dart';

class PasswordRecoveryState extends Equatable {
  final int step;
  final bool isLoading;
  final String? username;
  final String? resetToken;
  final String? errorMessage;
  final String? successMessage;
  final bool isCompleted;

  const PasswordRecoveryState({
    this.step = 1,
    this.isLoading = false,
    this.username,
    this.resetToken,
    this.errorMessage,
    this.successMessage,
    this.isCompleted = false,
  });

  PasswordRecoveryState copyWith({
    int? step,
    bool? isLoading,
    Object? username = _sentinel,
    Object? resetToken = _sentinel,
    Object? errorMessage = _sentinel,
    Object? successMessage = _sentinel,
    bool? isCompleted,
  }) {
    return PasswordRecoveryState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      username: identical(username, _sentinel) ? this.username : username as String?,
      resetToken: identical(resetToken, _sentinel) ? this.resetToken : resetToken as String?,
      errorMessage:
          identical(errorMessage, _sentinel) ? this.errorMessage : errorMessage as String?,
      successMessage: identical(successMessage, _sentinel)
          ? this.successMessage
          : successMessage as String?,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
        step,
        isLoading,
        username,
        resetToken,
        errorMessage,
        successMessage,
        isCompleted,
      ];
}
