import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/reference/domain/entities/reference_entities.dart';
import 'package:juyo/features/reference/domain/repositories/reference_repository.dart';

class GetMajorsUseCase {
  final ReferenceRepository repository;

  const GetMajorsUseCase(this.repository);

  Future<Result<List<MajorEntity>>> call(int universityId) {
    return repository.getMajors(universityId);
  }
}
