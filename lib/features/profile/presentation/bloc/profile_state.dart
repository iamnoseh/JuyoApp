import 'package:equatable/equatable.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileSaving extends ProfileState {
  final Profile? profile;

  const ProfileSaving(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final Profile profile;

  const ProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileFailure extends ProfileState {
  final String message;
  final Profile? profile;

  const ProfileFailure(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}
