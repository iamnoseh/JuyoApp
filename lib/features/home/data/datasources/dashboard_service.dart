import 'package:dio/dio.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/features/home/data/models/dashboard_stats_model.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';

class DashboardService {
  static Future<String> fetchMotivation() async {
    try {
      final response = await ApiClient.dio.get('/Dashboard/motivation');
      
      if (response.data is String) {
        return response.data;
      }
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'].toString();
      }
      return 'Знание — это единственное сокровище, которое растёт, когда им делятся.';
    } catch (e) {
      return 'Знание — это единственное сокровище, которое растёт, когда им делятся.';
    }
  }

  static Future<DashboardStatsModel?> fetchStudentStats() async {
    try {
      final response = await ApiClient.dio.get('/Dashboard/student-stats');
      
      if (response.statusCode == 200 && response.data != null) {
        // Backend sometimes wraps in data, sometimes returns directly
        final data = response.data['data'] ?? response.data;
        return DashboardStatsModel.fromJson(data);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
         print('Dashboard stats error: \${e.response?.data}');
      }
      return null;
    }
  }

  static Future<AdmissionStatsModel?> fetchAdmissionStats() async {
    try {
      final response = await ApiClient.dio.get('/Admission/stats');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return AdmissionStatsModel.fromJson(data);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        // Not configured target university, it's normal
        return null; 
      }
      print('Admission stats error: $e');
      return null;
    }
  }
}
