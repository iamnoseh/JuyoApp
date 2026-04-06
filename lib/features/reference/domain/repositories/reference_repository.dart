import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/reference/domain/entities/reference_entities.dart';

abstract class ReferenceRepository {
  Future<Result<List<SchoolEntity>>> getSchools({String? province});
  Future<Result<List<UniversityEntity>>> getUniversities();
  Future<Result<List<MajorEntity>>> getMajors(int universityId);
}
