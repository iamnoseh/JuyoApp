import 'package:juyo/features/reference/domain/entities/reference_entities.dart';

class SchoolModel extends SchoolEntity {
  const SchoolModel({
    required super.id,
    required super.name,
    required super.province,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      province: json['province']?.toString(),
    );
  }
}

class UniversityModel extends UniversityEntity {
  const UniversityModel({
    required super.id,
    required super.name,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class MajorModel extends MajorEntity {
  const MajorModel({
    required super.id,
    required super.name,
  });

  factory MajorModel.fromJson(Map<String, dynamic> json) {
    return MajorModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
