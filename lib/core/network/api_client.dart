import 'package:dio/dio.dart';
import 'package:juyo/app/di/service_locator.dart';

class ApiClient {
  final Dio client;

  const ApiClient(this.client);

  static Dio get shared => getIt<Dio>();

  static Dio get dioInstance => getIt<Dio>();

  // Temporary bridge for current service-based screens until the next phase removes them.
  static Dio get dio => getIt<Dio>();
}
