import 'package:equatable/equatable.dart';
import 'package:juyo/features/profile/data/models/update_profile_request_model.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

class ProfileSeeded extends ProfileEvent {
  final Profile profile;

  const ProfileSeeded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateRequested extends ProfileEvent {
  final UpdateProfileRequestModel request;

  const ProfileUpdateRequested(this.request);

  @override
  List<Object?> get props => [request];
}
