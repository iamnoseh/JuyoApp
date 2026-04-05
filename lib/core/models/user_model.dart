class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? profilePictureUrl;
  final String role;
  
  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] ?? json['FirstName'] ?? '';
    final lastName = json['lastName'] ?? json['LastName'] ?? '';
    String computedName = '$firstName $lastName'.trim();

    if (computedName.isEmpty) {
       computedName = json['userName'] ?? json['username'] ?? json['email'] ?? '';
    }

    return UserModel(
      id: json['id'] ?? '',
      fullName: computedName.isNotEmpty ? computedName : 'Пользователь',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? json['avatarUrl'] ?? json['AvatarUrl'],
      role: json['role'] ?? 'Student',
    );
  }
}
