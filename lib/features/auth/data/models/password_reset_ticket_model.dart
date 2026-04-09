import 'package:juyo/features/auth/domain/entities/password_reset_ticket.dart';

class PasswordResetTicketModel extends PasswordResetTicket {
  const PasswordResetTicketModel({
    required super.resetToken,
    required super.message,
  });

  factory PasswordResetTicketModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return PasswordResetTicketModel(
      resetToken: data['resetToken']?.toString() ?? '',
      message: json['message']?.toString() ?? data['message']?.toString() ?? '',
    );
  }
}
