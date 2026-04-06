import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/home/domain/entities/dashboard_data.dart';
import 'package:juyo/features/home/domain/repositories/dashboard_repository.dart';

class GetDashboardDataUseCase {
  final DashboardRepository repository;

  const GetDashboardDataUseCase(this.repository);

  Future<Result<DashboardData>> call() {
    return repository.getDashboardData();
  }
}
