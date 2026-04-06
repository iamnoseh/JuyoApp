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

  factory LeagueLeaderboardModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    // Assuming backend returns id, fullName/name, and points/xp
    final id = json['id']?.toString() ?? '';
    final firstName = json['firstName'] ?? '';
    final lastName = json['lastName'] ?? '';
    final fullName = json['fullName'] ?? '$firstName $lastName'.trim();
    
    return LeagueLeaderboardModel(
      rank: json['rank'] ?? 0,
      name: fullName.isNotEmpty ? fullName : 'Пользователь',
      xp: '${json['xp'] ?? json['points'] ?? 0} XP',
      isMe: id == currentUserId,
    );
  }
}
