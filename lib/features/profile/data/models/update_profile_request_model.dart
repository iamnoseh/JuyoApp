import 'package:dio/dio.dart';

class UpdateProfileRequestModel {
  final String? firstName;
  final String? lastName;
  final int? gender;
  final String? province;
  final int? schoolId;
  final int? grade;
  final int? clusterId;
  final int? targetUniversityId;
  final int? targetMajorId;
  final DateTime? dateOfBirth;
  final MultipartFile? avatar;

  const UpdateProfileRequestModel({
    this.firstName,
    this.lastName,
    this.gender,
    this.province,
    this.schoolId,
    this.grade,
    this.clusterId,
    this.targetUniversityId,
    this.targetMajorId,
    this.dateOfBirth,
    this.avatar,
  });

  FormData toFormData() {
    return FormData.fromMap({
      if (firstName != null) 'FirstName': firstName,
      if (lastName != null) 'LastName': lastName,
      if (gender != null) 'Gender': gender,
      if (province != null) 'Province': province,
      if (schoolId != null) 'SchoolId': schoolId,
      if (grade != null) 'Grade': grade,
      if (clusterId != null) 'ClusterId': clusterId,
      if (targetUniversityId != null) 'TargetUniversityId': targetUniversityId,
      if (targetMajorId != null) 'TargetMajorId': targetMajorId,
      if (dateOfBirth != null) 'DateOfBirth': dateOfBirth!.toIso8601String(),
      if (avatar != null) 'Avatar': avatar,
    });
  }
}
