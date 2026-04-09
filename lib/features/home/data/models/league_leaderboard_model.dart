class LeagueLeaderboardModel {
  final int rank;
  final String name;
  final String xp;
  final bool isMe;
  final String? schoolName;
  final String? avatarUrl;
  final bool isPremium;
  final String trend;
  final int weeklyXp;

  LeagueLeaderboardModel({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isMe,
    this.schoolName,
    this.avatarUrl,
    this.isPremium = false,
    this.trend = 'STABLE',
    this.weeklyXp = 0,
  });

  factory LeagueLeaderboardModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final id =
        (json['id'] ??
                json['Id'] ??
                json['userId'] ??
                json['UserId'])?.toString() ??
            '';
    final firstName = (json['firstName'] ?? json['FirstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? json['LastName'] ?? '').toString();
    final userFullName =
        (json['userFullName'] ?? json['UserFullName'] ?? '').toString();
    final fullName =
        (json['fullName'] ??
                json['FullName'] ??
                userFullName ??
                '$firstName $lastName'.trim())
            .toString();
    final weeklyXp =
        json['weeklyXP'] ??
        json['WeeklyXP'] ??
        json['xp'] ??
        json['XP'] ??
        json['points'] ??
        json['Points'] ??
        0;
    final premium = json['isPremium'] ?? json['IsPremium'] ?? false;

    return LeagueLeaderboardModel(
      rank: json['rank'] ?? json['Rank'] ?? 0,
      name: fullName.isNotEmpty ? fullName : 'User',
      xp: '$weeklyXp XP',
      isMe:
          (json['isCurrentUser'] ?? json['IsCurrentUser']) == true ||
          id == currentUserId,
      schoolName: (json['schoolName'] ?? json['SchoolName'])?.toString(),
      avatarUrl:
          (json['avatarUrl'] ??
                  json['AvatarUrl'] ??
                  json['profilePictureUrl'] ??
                  json['ProfilePictureUrl'])?.toString(),
      isPremium: premium == true || premium == 1,
      trend: ((json['trend'] ?? json['Trend'])?.toString() ?? 'STABLE')
          .toUpperCase(),
      weeklyXp: int.tryParse(weeklyXp.toString()) ?? 0,
    );
  }
}
