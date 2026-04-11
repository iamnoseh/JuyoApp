import 'package:dio/dio.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/features/red_list/data/models/red_list_dashboard_model.dart';

class RedListRepository {
  const RedListRepository();

  Future<RedListDashboardModel> getDashboard() async {
    final response = await ApiClient.dio.get('/RedList/dashboard');
    final body = response.data;
    final data = body is Map ? (body['data'] ?? body) : body;

    if (data is! Map) {
      throw const RedListRepositoryException('Invalid Red List response');
    }

    return RedListDashboardModel.fromMap(Map<dynamic, dynamic>.from(data));
  }

  Future<String> explainQuestion(int questionId) async {
    final response = await ApiClient.dio.post('/ai/explain/$questionId');
    final data = response.data;

    if (data is Map) {
      final explanation = data['explanation'] ?? data['Explanation'] ?? data['data'];
      if (explanation != null) {
        final text = explanation.toString().trim();
        if (text.isNotEmpty) return text;
      }
    }

    final text = data?.toString().trim() ?? '';
    if (text.isEmpty) {
      throw const RedListRepositoryException('Empty explanation');
    }
    return text;
  }
}

class RedListRepositoryException implements Exception {
  final String message;

  const RedListRepositoryException(this.message);

  @override
  String toString() => message;
}

bool isRedListLockedError(Object error) {
  if (error is DioException) {
    return error.response?.statusCode == 403;
  }
  return false;
}
