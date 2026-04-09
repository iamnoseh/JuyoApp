import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juyo/app/di/service_locator.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_event.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_state.dart';
import 'package:juyo/features/profile/presentation/pages/profile_edit_route_page.dart';

class ProfileRoutePage extends StatelessWidget {
  const ProfileRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const _ProfileRouteView(),
    );
  }
}

class _ProfileRouteView extends StatelessWidget {
  const _ProfileRouteView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.profileTitle,
      subtitle: l10n.dashboardOpenProfile,
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.aqua));
          }

          if (state is ProfileFailure && state.profile == null) {
            return ErrorState(title: l10n.errorTitle, subtitle: state.message);
          }

          final profile = switch (state) {
            ProfileLoaded(:final profile) => profile,
            ProfileSaving(:final profile?) => profile,
            ProfileUpdateSuccess(:final profile) => profile,
            ProfileFailure(profile: final profile?) => profile,
            _ => null,
          };

          if (profile == null) {
            return EmptyState(
              title: l10n.emptyTitle,
              subtitle: l10n.emptySubtitle,
            );
          }

          return Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.aqua.withValues(alpha: 0.18),
                      backgroundImage: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                          ? null
                          : NetworkImage(profile.avatarUrl!),
                      child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                          ? Text(
                              profile.fullName.isEmpty ? 'U' : profile.fullName[0].toUpperCase(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(profile.fullName, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(profile.phoneNumber, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    AppPrimaryButton(
                      label: l10n.profileEdit,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileEditRoutePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(title: 'XP', value: '${profile.xp}'),
              const SizedBox(height: 12),
              _InfoRow(title: 'ELO', value: '${profile.eloRating}'),
              const SizedBox(height: 12),
              _InfoRow(title: 'School', value: profile.schoolName ?? '-'),
              const SizedBox(height: 12),
              _InfoRow(title: 'Cluster', value: profile.clusterName ?? '-'),
              const SizedBox(height: 12),
              _InfoRow(title: 'League', value: profile.currentLeagueName ?? '-'),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
