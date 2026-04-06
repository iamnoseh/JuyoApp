import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:juyo/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_event.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileRefreshRequested>(_onRefreshRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileSeeded>(_onSeeded);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getProfileUseCase();
    switch (result) {
      case Success(data: final profile):
        emit(ProfileLoaded(profile));
      case Error(failure: final failure):
        emit(ProfileFailure(failure.message));
    }
  }

  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await getProfileUseCase();
    switch (result) {
      case Success(data: final profile):
        emit(ProfileLoaded(profile));
      case Error(failure: final failure):
        emit(ProfileFailure(failure.message));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = state is ProfileLoaded ? (state as ProfileLoaded).profile : null;
    emit(ProfileSaving(currentProfile));
    final result = await updateProfileUseCase(event.request);
    switch (result) {
      case Success(data: final profile):
        emit(ProfileUpdateSuccess(profile));
        emit(ProfileLoaded(profile));
      case Error(failure: final failure):
        emit(ProfileFailure(failure.message, profile: currentProfile));
        if (currentProfile != null) {
          emit(ProfileLoaded(currentProfile));
        }
    }
  }

  void _onSeeded(
    ProfileSeeded event,
    Emitter<ProfileState> emit,
  ) {
    emit(ProfileLoaded(event.profile));
  }
}
