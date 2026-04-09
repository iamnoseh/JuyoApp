import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/core/widgets/aurora_background.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_event.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_state.dart';
import 'package:juyo/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_bloc.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_event.dart';

class ProfileEditRoutePage extends StatelessWidget {
  const ProfileEditRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: BlocProvider(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              final profile = switch (state) {
                ProfileLoaded(:final profile) => profile,
                ProfileSaving(:final profile?) => profile,
                ProfileUpdateSuccess(:final profile) => profile,
                ProfileFailure(profile: final profile?) => profile,
                _ => null,
              };

              if (profile == null) {
                return const SizedBox.shrink();
              }

              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<ProfileBloc>()),
                  BlocProvider(
                    create: (_) => getIt<ReferenceBloc>()
                      ..add(
                        ReferenceLoadRequested(
                          selectedUniversityId: profile.targetUniversityId,
                        ),
                      ),
                  ),
                ],
                child: ProfileEditPage(profile: profile),
              );
            },
          ),
        ),
      ),
    );
  }
}
