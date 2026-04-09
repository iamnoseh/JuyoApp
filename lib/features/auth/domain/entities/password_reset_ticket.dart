import 'package:equatable/equatable.dart';

class PasswordResetTicket extends Equatable {
  final String resetToken;
  final String message;

  const PasswordResetTicket({
    required this.resetToken,
    required this.message,
  });

  @override
  List<Object?> get props => [resetToken, message];
}
