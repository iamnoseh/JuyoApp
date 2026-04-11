class SubjectTestSubject {
  final int id;
  final String name;
  final String? iconUrl;
  final String? iconPath;

  const SubjectTestSubject({
    required this.id,
    required this.name,
    this.iconUrl,
    this.iconPath,
  });

  factory SubjectTestSubject.fromMap(Map<String, dynamic> map) {
    return SubjectTestSubject(
      id: _readInt(map, const ['id', 'Id']),
      name: _readString(map, const ['name', 'Name']),
      iconUrl: _readNullableString(map, const ['iconUrl', 'IconUrl']),
      iconPath: _readNullableString(map, const ['iconPath', 'IconPath']),
    );
  }

  String? get imagePath {
    if (iconUrl != null && iconUrl!.trim().isNotEmpty) return iconUrl;
    if (iconPath != null && iconPath!.trim().isNotEmpty) return iconPath;
    return null;
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
