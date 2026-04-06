class AuthResponseModel {
  final String token;
  final String? userId;
  final String? role;

  const AuthResponseModel({
    required this.token,
    required this.userId,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthResponseModel(
      token: data['token']?.toString() ?? '',
      userId: data['userId']?.toString(),
      role: data['role']?.toString(),
    );
  }
}
