import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/features/tests/data/models/test_session_models.dart';

class TestSessionRepository {
  const TestSessionRepository();

  Future<List<TestQuestionModel>> getQuestions(String sessionId) async {
    final response = await ApiClient.dio.get('/Test/$sessionId/questions');
    final raw = response.data;

    final list = raw is List
        ? raw
        : raw is Map<String, dynamic>
            ? _extractList(raw)
            : raw is Map
                ? _extractList(Map<String, dynamic>.from(raw))
                : const [];

    return list
        .whereType<Map>()
        .map(
          (item) => TestQuestionModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((question) => question.id > 0)
        .toList();
  }

  Future<SubmitAnswerFeedbackModel> submitAnswer({
    required String sessionId,
    required int questionId,
    int? chosenAnswerId,
    String? textResponse,
    bool requestAiFeedback = false,
  }) async {
    final response = await ApiClient.dio.post(
      '/Test/answer',
      data: {
        'TestSessionId': sessionId,
        'QuestionId': questionId,
        'ChosenAnswerId': chosenAnswerId,
        'TextResponse': textResponse,
        'RequestAiFeedback': requestAiFeedback,
      },
    );

    final body = _extractMap(response.data);
    return SubmitAnswerFeedbackModel.fromMap(body);
  }

  Future<TestSessionResultModel> finishTest(String sessionId) async {
    final response = await ApiClient.dio.post('/Test/$sessionId/finish');
    final body = _extractMap(response.data);
    return TestSessionResultModel.fromMap(body);
  }

  List<dynamic> _extractList(Map<String, dynamic> map) {
    final candidates = [
      map['data'],
      map['Data'],
      map['questions'],
      map['Questions'],
      map['results'],
      map['Results'],
      map['items'],
      map['Items'],
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
    return const <String, dynamic>{};
  }
}
