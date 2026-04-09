import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/usecases/login_use_case.dart';
import 'package:juyo/features/auth/domain/usecases/logout_use_case.dart';
import 'package:juyo/features/auth/domain/usecases/register_use_case.dart';
import 'package:juyo/features/auth/domain/usecases/restore_session_use_case.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_event.dart';
import 'package:juyo/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.restoreSessionUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await restoreSessionUseCase();

    switch (result) {
      case Success(data: final session):
        emit(AuthenticatedState(session));
      case Error():
        emit(const UnauthenticatedState());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoginInProgress());
    final result = await loginUseCase(
      username: event.username,
      password: event.password,
    );

    switch (result) {
      case Success(data: final session):
        emit(AuthenticatedState(session));
      case Error(failure: final failure):
        emit(AuthFailureState(failure.message));
        emit(const UnauthenticatedState());
    }
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase();
    emit(const UnauthenticatedState());
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthRegisterInProgress());
    final result = await registerUseCase(
      phoneNumber: event.phoneNumber,
      firstName: event.firstName,
      lastName: event.lastName,
      password: event.password,
      confirmPassword: event.confirmPassword,
      referralCode: event.referralCode,
    );

    switch (result) {
      case Success(data: final session):
        emit(AuthenticatedState(session));
      case Error(failure: final failure):
        emit(AuthFailureState(failure.message));
        emit(const UnauthenticatedState());
    }
  }
}
