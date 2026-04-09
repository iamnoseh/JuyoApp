import 'package:equatable/equatable.dart';
import 'package:juyo/features/auth/domain/entities/auth_session.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthLoginInProgress extends AuthState {
  const AuthLoginInProgress();
}

class AuthRegisterInProgress extends AuthState {
  const AuthRegisterInProgress();
}

class AuthenticatedState extends AuthState {
  final AuthSession session;

  const AuthenticatedState(this.session);

  @override
  List<Object?> get props => [session];
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
