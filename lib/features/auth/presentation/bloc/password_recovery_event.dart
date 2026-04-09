import 'package:equatable/equatable.dart';

abstract class PasswordRecoveryEvent extends Equatable {
  const PasswordRecoveryEvent();

  @override
  List<Object?> get props => [];
}

class PasswordRecoveryOtpRequested extends PasswordRecoveryEvent {
  final String username;

  const PasswordRecoveryOtpRequested(this.username);

  @override
  List<Object?> get props => [username];
}

class PasswordRecoveryOtpVerificationRequested extends PasswordRecoveryEvent {
  final String username;
  final String otpCode;

  const PasswordRecoveryOtpVerificationRequested({
    required this.username,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [username, otpCode];
}

class PasswordRecoveryResetRequested extends PasswordRecoveryEvent {
  final String phoneNumber;
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  const PasswordRecoveryResetRequested({
    required this.phoneNumber,
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [phoneNumber, resetToken, newPassword, confirmPassword];
}

class PasswordRecoveryErrorConsumed extends PasswordRecoveryEvent {
  const PasswordRecoveryErrorConsumed();
}

class PasswordRecoveryRestarted extends PasswordRecoveryEvent {
  const PasswordRecoveryRestarted();
}
