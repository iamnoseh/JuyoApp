enum TestQuestionType {
  singleChoice(1),
  matching(2),
  closedAnswer(3);

  final int value;

  const TestQuestionType(this.value);

  static TestQuestionType fromValue(int value) {
    return TestQuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TestQuestionType.singleChoice,
    );
  }
}

class TestAnswerOption {
  final int id;
  final String text;
  final String? matchPairText;

  const TestAnswerOption({
    required this.id,
    required this.text,
    this.matchPairText,
  });

  factory TestAnswerOption.fromMap(Map<String, dynamic> map) {
    return TestAnswerOption(
      id: _readInt(map, const ['id', 'Id']),
      text: _readString(map, const ['text', 'Text', 'answer', 'Answer']),
      matchPairText: _readNullableString(
        map,
        const ['matchPairText', 'MatchPairText', 'matchPair', 'MatchPair'],
      ),
    );
  }
}

class TestQuestionModel {
  final int id;
  final String content;
  final String? imageUrl;
  final int subjectId;
  final String subjectName;
  final String? topic;
  final int difficulty;
  final TestQuestionType type;
  final List<TestAnswerOption> answers;
  final List<String> matchOptions;
  final bool isInRedList;
  final int redListCorrectCount;

  const TestQuestionModel({
    required this.id,
    required this.content,
    required this.imageUrl,
    required this.subjectId,
    required this.subjectName,
    required this.topic,
    required this.difficulty,
    required this.type,
    required this.answers,
    required this.matchOptions,
    required this.isInRedList,
    required this.redListCorrectCount,
  });

  factory TestQuestionModel.fromMap(Map<String, dynamic> map) {
    final answersRaw = map['answers'] ?? map['Answers'];
    final optionsRaw = map['matchOptions'] ?? map['MatchOptions'];

    return TestQuestionModel(
      id: _readInt(map, const ['id', 'Id']),
      content: _readString(map, const ['content', 'Content']),
      imageUrl: _readNullableString(map, const ['imageUrl', 'ImageUrl']),
      subjectId: _readInt(map, const ['subjectId', 'SubjectId']),
      subjectName: _readString(map, const ['subjectName', 'SubjectName']),
      topic: _readNullableString(map, const ['topic', 'Topic']),
      difficulty: _readInt(map, const ['difficulty', 'Difficulty']),
      type: TestQuestionType.fromValue(_readInt(map, const ['type', 'Type'])),
      answers: answersRaw is List
          ? answersRaw
              .whereType<Map>()
              .map(
                (item) => TestAnswerOption.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      matchOptions: optionsRaw is List
          ? optionsRaw.map((item) => item.toString()).toList()
          : const [],
      isInRedList: _readBool(map, const ['isInRedList', 'IsInRedList']),
      redListCorrectCount: _readInt(
        map,
        const ['redListCorrectCount', 'RedListCorrectCount'],
      ),
    );
  }
}

class ValidationPairModel {
  final String leftSide;
  final String rightSide;
  final String correctRightSide;
  final bool isCorrect;

  const ValidationPairModel({
    required this.leftSide,
    required this.rightSide,
    required this.correctRightSide,
    required this.isCorrect,
  });

  factory ValidationPairModel.fromMap(Map<String, dynamic> map) {
    return ValidationPairModel(
      leftSide: _readString(map, const ['leftSide', 'LeftSide']),
      rightSide: _readString(map, const ['rightSide', 'RightSide']),
      correctRightSide: _readString(
        map,
        const ['correctRightSide', 'CorrectRightSide'],
      ),
      isCorrect: _readBool(map, const ['isCorrect', 'IsCorrect']),
    );
  }
}

class SubmitAnswerFeedbackModel {
  final bool isCorrect;
  final String? correctAnswerText;
  final String? feedbackText;
  final int? score;
  final int? maxScore;
  final List<ValidationPairModel> validationPairs;
  final int? correctPairsCount;
  final int? totalPairsCount;

  const SubmitAnswerFeedbackModel({
    required this.isCorrect,
    required this.correctAnswerText,
    required this.feedbackText,
    required this.score,
    required this.maxScore,
    required this.validationPairs,
    required this.correctPairsCount,
    required this.totalPairsCount,
  });

  factory SubmitAnswerFeedbackModel.fromMap(Map<String, dynamic> map) {
    final pairsRaw = map['validationPairs'] ?? map['ValidationPairs'];

    return SubmitAnswerFeedbackModel(
      isCorrect: _readBool(map, const ['isCorrect', 'IsCorrect']),
      correctAnswerText: _readNullableString(
        map,
        const ['correctAnswerText', 'CorrectAnswerText'],
      ),
      feedbackText: _readNullableString(
        map,
        const ['feedbackText', 'FeedbackText'],
      ),
      score: _readNullableInt(map, const ['score', 'Score']),
      maxScore: _readNullableInt(map, const ['maxScore', 'MaxScore']),
      validationPairs: pairsRaw is List
          ? pairsRaw
              .whereType<Map>()
              .map(
                (item) => ValidationPairModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      correctPairsCount: _readNullableInt(
        map,
        const ['correctPairsCount', 'CorrectPairsCount'],
      ),
      totalPairsCount: _readNullableInt(
        map,
        const ['totalPairsCount', 'TotalPairsCount'],
      ),
    );
  }
}

class TestQuestionResultItem {
  final int questionId;
  final bool isCorrect;
  final int? userAnswerId;
  final String? userTextResponse;
  final int? correctAnswerId;
  final String? correctAnswerText;
  final String? explanation;

  const TestQuestionResultItem({
    required this.questionId,
    required this.isCorrect,
    required this.userAnswerId,
    required this.userTextResponse,
    required this.correctAnswerId,
    required this.correctAnswerText,
    required this.explanation,
  });

  factory TestQuestionResultItem.fromMap(Map<String, dynamic> map) {
    return TestQuestionResultItem(
      questionId: _readInt(map, const ['questionId', 'QuestionId']),
      isCorrect: _readBool(map, const ['isCorrect', 'IsCorrect']),
      userAnswerId: _readNullableInt(map, const ['userAnswerId', 'UserAnswerId']),
      userTextResponse: _readNullableString(
        map,
        const ['userTextResponse', 'UserTextResponse'],
      ),
      correctAnswerId: _readNullableInt(
        map,
        const ['correctAnswerId', 'CorrectAnswerId'],
      ),
      correctAnswerText: _readNullableString(
        map,
        const ['correctAnswerText', 'CorrectAnswerText'],
      ),
      explanation: _readNullableString(map, const ['explanation', 'Explanation']),
    );
  }
}

class TestSessionResultModel {
  final String testSessionId;
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final double percentage;
  final bool isPassed;
  final int xpEarned;
  final String? aiAnalysis;
  final List<TestQuestionResultItem> results;

  const TestSessionResultModel({
    required this.testSessionId,
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.isPassed,
    required this.xpEarned,
    required this.aiAnalysis,
    required this.results,
  });

  factory TestSessionResultModel.fromMap(Map<String, dynamic> map) {
    final resultsRaw = map['results'] ?? map['Results'];

    return TestSessionResultModel(
      testSessionId: _readString(
        map,
        const ['testSessionId', 'TestSessionId'],
      ),
      totalScore: _readInt(map, const ['totalScore', 'TotalScore']),
      correctAnswers: _readInt(map, const ['correctAnswers', 'CorrectAnswers']),
      totalQuestions: _readInt(map, const ['totalQuestions', 'TotalQuestions']),
      percentage: _readDouble(map, const ['percentage', 'Percentage']),
      isPassed: _readBool(map, const ['isPassed', 'IsPassed']),
      xpEarned: _readInt(map, const ['xpEarned', 'XpEarned']),
      aiAnalysis: _readNullableString(map, const ['aiAnalysis', 'AiAnalysis']),
      results: resultsRaw is List
          ? resultsRaw
              .whereType<Map>()
              .map(
                (item) => TestQuestionResultItem.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }
}

int _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

int? _readNullableInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

double _readDouble(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

bool _readBool(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    if (value is num) return value != 0;
  }
  return false;
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

String? _readNullableString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}
