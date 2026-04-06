class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? profilePictureUrl;
  final String role;
  final int xp;
  final int eloRating;
  final int streak;
  final int points;
  final String? currentLeagueName;
  final bool isPremium;
  
  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.profilePictureUrl,
    required this.role,
    this.xp = 0,
    this.eloRating = 1000,
    this.streak = 0,
    this.points = 0,
    this.currentLeagueName,
    this.isPremium = false,
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
      profilePictureUrl: json['profilePictureUrl'] ?? json['avatarUrl'] ?? json['AvatarUrl'] ?? json['Avatar'],
      role: json['role'] ?? 'Student',
      xp: json['xp'] ?? json['XP'] ?? 0,
      eloRating: json['eloRating'] ?? json['EloRating'] ?? 1000,
      streak: json['streak'] ?? json['Streak'] ?? 0,
      points: json['points'] ?? json['Points'] ?? 0,
      currentLeagueName: json['currentLeagueName'] ?? json['CurrentLeagueName'],
      isPremium: json['isPremium'] ?? json['IsPremium'] ?? false,
    );
  }
}
