import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:juyo/features/auth/domain/usecases/send_otp_use_case.dart';
import 'package:juyo/features/auth/domain/usecases/verify_otp_use_case.dart';
import 'package:juyo/features/auth/presentation/bloc/password_recovery_event.dart';
import 'package:juyo/features/auth/presentation/bloc/password_recovery_state.dart';

class PasswordRecoveryBloc
    extends Bloc<PasswordRecoveryEvent, PasswordRecoveryState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  PasswordRecoveryBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.resetPasswordUseCase,
  }) : super(const PasswordRecoveryState()) {
    on<PasswordRecoveryOtpRequested>(_onOtpRequested);
    on<PasswordRecoveryOtpVerificationRequested>(_onOtpVerificationRequested);
    on<PasswordRecoveryResetRequested>(_onResetRequested);
    on<PasswordRecoveryErrorConsumed>(_onErrorConsumed);
    on<PasswordRecoveryRestarted>(_onRestarted);
  }

  Future<void> _onOtpRequested(
    PasswordRecoveryOtpRequested event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        username: event.username,
      ),
    );

    final result = await sendOtpUseCase(username: event.username);
    switch (result) {
      case Success(data: final message):
        emit(
          state.copyWith(
            isLoading: false,
            step: 2,
            username: event.username,
            successMessage: message,
            errorMessage: null,
          ),
        );
      case Error(failure: final failure):
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            successMessage: null,
          ),
        );
    }
  }

  Future<void> _onOtpVerificationRequested(
    PasswordRecoveryOtpVerificationRequested event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await verifyOtpUseCase(
      username: event.username,
      otpCode: event.otpCode,
    );

    switch (result) {
      case Success(data: final ticket):
        emit(
          state.copyWith(
            isLoading: false,
            step: 3,
            username: event.username,
            resetToken: ticket.resetToken,
            successMessage: ticket.message,
            errorMessage: null,
          ),
        );
      case Error(failure: final failure):
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            successMessage: null,
          ),
        );
    }
  }

  Future<void> _onResetRequested(
    PasswordRecoveryResetRequested event,
    Emitter<PasswordRecoveryState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await resetPasswordUseCase(
      phoneNumber: event.phoneNumber,
      resetToken: event.resetToken,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    switch (result) {
      case Success(data: final message):
        emit(
          state.copyWith(
            isLoading: false,
            isCompleted: true,
            successMessage: message,
            errorMessage: null,
          ),
        );
      case Error(failure: final failure):
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            successMessage: null,
          ),
        );
    }
  }

  void _onErrorConsumed(
    PasswordRecoveryErrorConsumed event,
    Emitter<PasswordRecoveryState> emit,
  ) {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  void _onRestarted(
    PasswordRecoveryRestarted event,
    Emitter<PasswordRecoveryState> emit,
  ) {
    emit(const PasswordRecoveryState());
  }
}
