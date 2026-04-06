import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/reference/domain/entities/reference_entities.dart';
import 'package:juyo/features/reference/domain/repositories/reference_repository.dart';

class GetSchoolsUseCase {
  final ReferenceRepository repository;

  const GetSchoolsUseCase(this.repository);

  Future<Result<List<SchoolEntity>>> call({String? province}) {
    return repository.getSchools(province: province);
  }
}
