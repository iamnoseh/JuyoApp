import 'package:dio/dio.dart';
import 'package:juyo/core/error/failure.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/reference/data/datasources/reference_remote_data_source.dart';
import 'package:juyo/features/reference/domain/entities/reference_entities.dart';
import 'package:juyo/features/reference/domain/repositories/reference_repository.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  final ReferenceRemoteDataSource remoteDataSource;

  const ReferenceRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<SchoolEntity>>> getSchools({String? province}) async {
    try {
      final schools = await remoteDataSource.getSchools(province: province);
      return Success<List<SchoolEntity>>(schools);
    } on DioException catch (error) {
      final message = _errorMessage(error, 'Failed to load schools');
      return Error<List<SchoolEntity>>(NetworkFailure(message));
    } catch (_) {
      return const Error<List<SchoolEntity>>(
        NetworkFailure('Failed to load schools'),
      );
    }
  }

  @override
  Future<Result<List<UniversityEntity>>> getUniversities() async {
    try {
      final universities = await remoteDataSource.getUniversities();
      return Success<List<UniversityEntity>>(universities);
    } on DioException catch (error) {
      final message = _errorMessage(error, 'Failed to load universities');
      return Error<List<UniversityEntity>>(NetworkFailure(message));
    } catch (_) {
      return const Error<List<UniversityEntity>>(
        NetworkFailure('Failed to load universities'),
      );
    }
  }

  @override
  Future<Result<List<MajorEntity>>> getMajors(int universityId) async {
    try {
      final majors = await remoteDataSource.getMajors(universityId);
      return Success<List<MajorEntity>>(majors);
    } on DioException catch (error) {
      final message = _errorMessage(error, 'Failed to load majors');
      return Error<List<MajorEntity>>(NetworkFailure(message));
    } catch (_) {
      return const Error<List<MajorEntity>>(
        NetworkFailure('Failed to load majors'),
      );
    }
  }

  String _errorMessage(DioException error, String fallback) {
    final response = error.response?.data;
    if (response is Map<String, dynamic> && response['message'] is String) {
      return response['message'] as String;
    }
    return fallback;
  }
}
