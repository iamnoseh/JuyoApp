import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/core/error/result.dart';
import 'package:juyo/features/home/domain/usecases/get_dashboard_data_use_case.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_event.dart';
import 'package:juyo/features/home/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;

  DashboardBloc({
    required this.getDashboardDataUseCase,
  }) : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await getDashboardDataUseCase();
    switch (result) {
      case Success(data: final data):
        emit(DashboardLoaded(data));
      case Error(failure: final failure):
        emit(DashboardFailure(failure.message));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await getDashboardDataUseCase();
    switch (result) {
      case Success(data: final data):
        emit(DashboardLoaded(data));
      case Error(failure: final failure):
        emit(DashboardFailure(failure.message));
    }
  }
}
