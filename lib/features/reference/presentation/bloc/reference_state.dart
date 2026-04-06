import 'package:equatable/equatable.dart';
import 'package:juyo/features/reference/domain/entities/reference_entities.dart';

abstract class ReferenceState extends Equatable {
  const ReferenceState();

  @override
  List<Object?> get props => [];
}

class ReferenceInitial extends ReferenceState {
  const ReferenceInitial();
}

class ReferenceLoading extends ReferenceState {
  const ReferenceLoading();
}

class ReferenceLoaded extends ReferenceState {
  final List<SchoolEntity> schools;
  final List<UniversityEntity> universities;
  final List<MajorEntity> majors;

  const ReferenceLoaded({
    required this.schools,
    required this.universities,
    required this.majors,
  });

  ReferenceLoaded copyWith({
    List<SchoolEntity>? schools,
    List<UniversityEntity>? universities,
    List<MajorEntity>? majors,
  }) {
    return ReferenceLoaded(
      schools: schools ?? this.schools,
      universities: universities ?? this.universities,
      majors: majors ?? this.majors,
    );
  }

  @override
  List<Object?> get props => [schools, universities, majors];
}

class ReferenceFailure extends ReferenceState {
  final String message;

  const ReferenceFailure(this.message);

  @override
  List<Object?> get props => [message];
}
