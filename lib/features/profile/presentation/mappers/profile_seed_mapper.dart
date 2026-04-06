import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';

class ProfileSeedMapper {
  static Profile fromUserModel(UserModel user) {
    final parts = user.fullName.split(' ').where((part) => part.trim().isNotEmpty).toList();
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return Profile(
      userId: user.id,
      firstName: firstName,
      lastName: lastName,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      role: user.role,
      avatarUrl: user.profilePictureUrl,
      xp: user.xp,
      eloRating: user.eloRating,
      streak: user.streak,
      points: user.points,
      isPremium: user.isPremium,
      province: user.province,
      gender: user.gender,
      schoolId: user.schoolId,
      schoolName: user.schoolName,
      grade: user.grade,
      clusterName: user.clusterName,
      clusterId: user.clusterId,
      targetUniversity: user.targetUniversity,
      targetUniversityId: user.targetUniversityId,
      targetMajorName: user.targetMajorName,
      targetMajorId: user.targetMajorId,
      targetPassingScore: user.targetPassingScore,
      targetPassingScore2024: user.targetPassingScore2024,
      targetPassingScore2025: user.targetPassingScore2025,
      dateOfBirth: user.dateOfBirth,
      globalRank: user.globalRank,
      registrationDate: user.registrationDate,
      age: user.age,
      premiumExpiresAt: user.premiumExpiresAt,
      currentLeagueName: user.currentLeagueName,
      lastTestResults: user.lastTestResults
          .map(
            (test) => ProfileTestResult(
              id: test.id,
              mode: test.mode,
              totalScore: test.totalScore,
              subjectName: test.subjectName,
              finishedAt: test.finishedAt,
            ),
          )
          .toList(),
    );
  }
}
