import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:juyo/features/home/data/models/admission_stats_model.dart';

class ProfileOverviewCubit extends Cubit<ProfileOverviewState> {
  final DashboardRemoteDataSource remoteDataSource;

  ProfileOverviewCubit({
    required this.remoteDataSource,
  }) : super(const ProfileOverviewState());

  Future<void> load() async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
      ),
    );

    AdmissionStatsModel? admissionStats;
    List<SkillProgressModel> skills = state.skills;
    String? errorMessage;

    try {
      admissionStats = await remoteDataSource.getAdmissionStats();
    } on DioException catch (error) {
      errorMessage = _messageFromDio(error, fallback: 'Failed to load profile insights');
    } catch (_) {
      errorMessage = 'Failed to load profile insights';
    }

    try {
      skills = await remoteDataSource.getSkillsProgress();
    } on DioException catch (error) {
      errorMessage ??= _messageFromDio(error, fallback: 'Failed to load profile insights');
    } catch (_) {
      errorMessage ??= 'Failed to load profile insights';
    }

    emit(
      state.copyWith(
        isLoading: false,
        admissionStats: admissionStats,
        skills: skills,
        errorMessage: errorMessage,
      ),
    );
  }

  static String _messageFromDio(
    DioException error, {
    required String fallback,
  }) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}

class ProfileOverviewState extends Equatable {
  static const Object _sentinel = Object();

  final bool isLoading;
  final AdmissionStatsModel? admissionStats;
  final List<SkillProgressModel> skills;
  final String? errorMessage;

  const ProfileOverviewState({
    this.isLoading = false,
    this.admissionStats,
    this.skills = const [],
    this.errorMessage,
  });

  ProfileOverviewState copyWith({
    bool? isLoading,
    Object? admissionStats = _sentinel,
    List<SkillProgressModel>? skills,
    Object? errorMessage = _sentinel,
  }) {
    return ProfileOverviewState(
      isLoading: isLoading ?? this.isLoading,
      admissionStats: identical(admissionStats, _sentinel)
          ? this.admissionStats
          : admissionStats as AdmissionStatsModel?,
      skills: skills ?? this.skills,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        admissionStats,
        skills,
        errorMessage,
      ];
}
