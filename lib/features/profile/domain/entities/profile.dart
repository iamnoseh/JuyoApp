import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String userId;
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  const Profile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, avatarUrl];
}
