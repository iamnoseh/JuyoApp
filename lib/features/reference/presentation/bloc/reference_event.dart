import 'package:equatable/equatable.dart';

abstract class ReferenceEvent extends Equatable {
  const ReferenceEvent();

  @override
  List<Object?> get props => [];
}

class ReferenceLoadRequested extends ReferenceEvent {
  final int? selectedUniversityId;

  const ReferenceLoadRequested({this.selectedUniversityId});

  @override
  List<Object?> get props => [selectedUniversityId];
}

class ReferenceMajorsRequested extends ReferenceEvent {
  final int universityId;

  const ReferenceMajorsRequested(this.universityId);

  @override
  List<Object?> get props => [universityId];
}
