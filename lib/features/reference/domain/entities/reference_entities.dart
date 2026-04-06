import 'package:equatable/equatable.dart';

class SchoolEntity extends Equatable {
  final int id;
  final String name;
  final String? province;

  const SchoolEntity({
    required this.id,
    required this.name,
    required this.province,
  });

  @override
  List<Object?> get props => [id, name, province];
}

class UniversityEntity extends Equatable {
  final int id;
  final String name;

  const UniversityEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class MajorEntity extends Equatable {
  final int id;
  final String name;

  const MajorEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
