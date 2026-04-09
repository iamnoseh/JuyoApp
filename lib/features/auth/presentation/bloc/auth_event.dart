import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String password;
  final String confirmPassword;
  final String? referralCode;

  const AuthRegisterRequested({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.confirmPassword,
    this.referralCode,
  });

  @override
  List<Object?> get props => [
        phoneNumber,
        firstName,
        lastName,
        password,
        confirmPassword,
        referralCode,
      ];
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}
