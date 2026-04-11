class RedListDashboardModel {
  final RedListStatsModel stats;
  final List<RedListChartPointModel> chartData;
  final List<RedListQuestionModel> activeQuestions;

  const RedListDashboardModel({
    required this.stats,
    required this.chartData,
    required this.activeQuestions,
  });

  factory RedListDashboardModel.fromMap(Map<dynamic, dynamic> json) {
    final statsRaw = _asMap(json['stats'] ?? json['Stats']);
    final chartRaw = _asList(json['chartData'] ?? json['ChartData']);
    final questionsRaw = _asList(json['activeQuestions'] ?? json['ActiveQuestions']);

    return RedListDashboardModel(
      stats: RedListStatsModel.fromMap(statsRaw),
      chartData: chartRaw
          .whereType<Map>()
          .map((item) => RedListChartPointModel.fromMap(item))
          .toList(),
      activeQuestions: questionsRaw
          .whereType<Map>()
          .map((item) => RedListQuestionModel.fromMap(item))
          .toList(),
    );
  }
}

class RedListStatsModel {
  final int totalQuestions;
  final int newQuestionsToday;
  final int xpToday;
  final int xpIncreasePercent;
  final int readyToRemoveCount;
  final int removedTodayCount;

  const RedListStatsModel({
    required this.totalQuestions,
    required this.newQuestionsToday,
    required this.xpToday,
    required this.xpIncreasePercent,
    required this.readyToRemoveCount,
    required this.removedTodayCount,
  });

  factory RedListStatsModel.fromMap(Map<dynamic, dynamic> json) {
    return RedListStatsModel(
      totalQuestions: _readInt(json, const ['totalQuestions', 'TotalQuestions']),
      newQuestionsToday: _readInt(
        json,
        const ['newQuestionsToday', 'NewQuestionsToday'],
      ),
      xpToday: _readInt(json, const ['xpToday', 'XPToday']),
      xpIncreasePercent: _readInt(
        json,
        const ['xpIncreasePercent', 'XPIncreasePercent'],
      ),
      readyToRemoveCount: _readInt(
        json,
        const ['readyToRemoveCount', 'ReadyToRemoveCount'],
      ),
      removedTodayCount: _readInt(
        json,
        const ['removedTodayCount', 'RemovedTodayCount'],
      ),
    );
  }
}

class RedListChartPointModel {
  final String dateLabel;
  final int value;
  final int addedCount;
  final int removedCount;

  const RedListChartPointModel({
    required this.dateLabel,
    required this.value,
    required this.addedCount,
    required this.removedCount,
  });

  factory RedListChartPointModel.fromMap(Map<dynamic, dynamic> json) {
    return RedListChartPointModel(
      dateLabel: _readString(
        json,
        const ['dateLabel', 'DateLabel'],
        fallback: '',
      ),
      value: _readInt(json, const ['value', 'Value']),
      addedCount: _readInt(json, const ['addedCount', 'AddedCount']),
      removedCount: _readInt(json, const ['removedCount', 'RemovedCount']),
    );
  }
}

class RedListQuestionModel {
  final int id;
  final int questionId;
  final String content;
  final String? imageUrl;
  final String subjectName;
  final String topic;
  final DateTime? addedAt;
  final int consecutiveCorrectCount;

  const RedListQuestionModel({
    required this.id,
    required this.questionId,
    required this.content,
    required this.imageUrl,
    required this.subjectName,
    required this.topic,
    required this.addedAt,
    required this.consecutiveCorrectCount,
  });

  factory RedListQuestionModel.fromMap(Map<dynamic, dynamic> json) {
    return RedListQuestionModel(
      id: _readInt(json, const ['id', 'Id']),
      questionId: _readInt(json, const ['questionId', 'QuestionId']),
      content: _readString(json, const ['content', 'Content'], fallback: ''),
      imageUrl: _readNullableString(json, const ['imageUrl', 'ImageUrl']),
      subjectName: _readString(
        json,
        const ['subjectName', 'SubjectName'],
        fallback: 'Subject',
      ),
      topic: _readString(json, const ['topic', 'Topic'], fallback: 'General'),
      addedAt: DateTime.tryParse(
        _readString(json, const ['addedAt', 'AddedAt'], fallback: ''),
      ),
      consecutiveCorrectCount: _readInt(
        json,
        const ['consecutiveCorrectCount', 'ConsecutiveCorrectCount'],
      ),
    );
  }
}

Map<dynamic, dynamic> _asMap(dynamic value) {
  if (value is Map<dynamic, dynamic>) return value;
  if (value is Map) return Map<dynamic, dynamic>.from(value);
  return <dynamic, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is List) return List<dynamic>.from(value);
  return const [];
}

int _readInt(
  Map<dynamic, dynamic> json,
  List<String> keys, {
  int fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return fallback;
}

String _readString(
  Map<dynamic, dynamic> json,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return fallback;
}

String? _readNullableString(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return null;
}
