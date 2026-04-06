import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/reference/domain/entities/reference_entities.dart';
import 'package:juyo/features/reference/domain/repositories/reference_repository.dart';

class GetUniversitiesUseCase {
  final ReferenceRepository repository;

  const GetUniversitiesUseCase(this.repository);

  Future<Result<List<UniversityEntity>>> call() {
    return repository.getUniversities();
  }
}
