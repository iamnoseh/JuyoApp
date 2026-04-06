import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/reference/domain/entities/reference_entities.dart';
import 'package:juyo/features/reference/domain/usecases/get_majors_use_case.dart';
import 'package:juyo/features/reference/domain/usecases/get_schools_use_case.dart';
import 'package:juyo/features/reference/domain/usecases/get_universities_use_case.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_event.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_state.dart';

class ReferenceBloc extends Bloc<ReferenceEvent, ReferenceState> {
  final GetSchoolsUseCase getSchoolsUseCase;
  final GetUniversitiesUseCase getUniversitiesUseCase;
  final GetMajorsUseCase getMajorsUseCase;

  ReferenceBloc({
    required this.getSchoolsUseCase,
    required this.getUniversitiesUseCase,
    required this.getMajorsUseCase,
  }) : super(const ReferenceInitial()) {
    on<ReferenceLoadRequested>(_onLoadRequested);
    on<ReferenceMajorsRequested>(_onMajorsRequested);
  }

  Future<void> _onLoadRequested(
    ReferenceLoadRequested event,
    Emitter<ReferenceState> emit,
  ) async {
    emit(const ReferenceLoading());

    final schoolsResult = await getSchoolsUseCase();
    final universitiesResult = await getUniversitiesUseCase();

    if (schoolsResult case Error(failure: final failure)) {
      emit(ReferenceFailure(failure.message));
      return;
    }

    if (universitiesResult case Error(failure: final failure)) {
      emit(ReferenceFailure(failure.message));
      return;
    }

    final schools = (schoolsResult as Success<List<SchoolEntity>>).data;
    final universities = (universitiesResult as Success<List<UniversityEntity>>).data;

    var majors = <MajorEntity>[];
    if (event.selectedUniversityId != null) {
      final majorsResult = await getMajorsUseCase(event.selectedUniversityId!);
      if (majorsResult case Success(data: final data)) {
        majors = data;
      }
    }

    emit(
      ReferenceLoaded(
        schools: schools,
        universities: universities,
        majors: majors,
      ),
    );
  }

  Future<void> _onMajorsRequested(
    ReferenceMajorsRequested event,
    Emitter<ReferenceState> emit,
  ) async {
    final current = state;
    if (current is! ReferenceLoaded) return;

    final majorsResult = await getMajorsUseCase(event.universityId);
    switch (majorsResult) {
      case Success(data: final majors):
        emit(current.copyWith(majors: majors));
      case Error(failure: final failure):
        emit(ReferenceFailure(failure.message));
        emit(current);
    }
  }
}
