class LeagueLeaderboardModel {
  final int rank;
  final String name;
  final String xp;
  final bool isMe;

  LeagueLeaderboardModel({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isMe,
  });

  factory LeagueLeaderboardModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final id = (json['id'] ?? json['Id'])?.toString() ?? '';
    final firstName = (json['firstName'] ?? json['FirstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? json['LastName'] ?? '').toString();
    final fullName =
        (json['fullName'] ?? json['FullName'] ?? '$firstName $lastName'.trim())
            .toString();

    return LeagueLeaderboardModel(
      rank: json['rank'] ?? json['Rank'] ?? 0,
      name: fullName.isNotEmpty ? fullName : 'Пользователь',
      xp:
          '${json['xp'] ?? json['XP'] ?? json['points'] ?? json['Points'] ?? 0} XP',
      isMe: id == currentUserId,
    );
  }
}
