import 'package:dio/dio.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/features/tests/data/models/subject_test_subject.dart';

class SubjectTestsRepository {
  const SubjectTestsRepository();

  Future<List<SubjectTestSubject>> getSubjects() async {
    final response = await ApiClient.dio.get('/Subject');
    final raw = response.data;

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => SubjectTestSubject.fromMap(
                Map<String, dynamic>.from(item),
              ))
          .where((subject) => subject.id > 0 && subject.name.isNotEmpty)
          .toList();
    }

    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};

    final list = _extractList(map);
    return list
        .whereType<Map>()
        .map((item) => SubjectTestSubject.fromMap(
              Map<String, dynamic>.from(item),
            ))
        .where((subject) => subject.id > 0 && subject.name.isNotEmpty)
        .toList();
  }

  Future<String> startSubjectTest(int subjectId) async {
    final response = await ApiClient.dio.post(
      '/Test/start',
      data: {
        'Mode': 4,
        'SubjectId': subjectId,
      },
    );

    final body = _extractMap(response.data);
    final sessionId = _readString(
      body,
      const ['testSessionId', 'TestSessionId', 'sessionId', 'SessionId'],
    );

    if (sessionId.isEmpty) {
      throw const SubjectTestsRepositoryException('Empty test session id');
    }

    return sessionId;
  }

  List<dynamic> _extractList(Map<String, dynamic> map) {
    final candidates = [
      map['data'],
      map['Data'],
      map['subjects'],
      map['Subjects'],
      map['items'],
      map['Items'],
      map['results'],
      map['Results'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) return candidate;
    }

    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final nested = raw['data'] ?? raw['Data'];
      if (nested is Map<String, dynamic>) return nested;
      return raw;
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final nested = map['data'] ?? map['Data'];
      if (nested is Map) return Map<String, dynamic>.from(nested);
      return map;
    }
    throw const SubjectTestsRepositoryException('Invalid response');
  }
}

class SubjectTestsRepositoryException implements Exception {
  final String message;

  const SubjectTestsRepositoryException(this.message);

  @override
  String toString() => message;
}

String _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

bool isSubjectTestForbidden(Object error) {
  if (error is! DioException) return false;
  return error.response?.statusCode == 403;
}
