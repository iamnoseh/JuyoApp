import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/home/domain/entities/dashboard_data.dart';

abstract class DashboardRepository {
  Future<Result<DashboardData>> getDashboardData();
}
