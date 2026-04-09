import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class SchoolLeaderboardPage extends StatefulWidget {
  const SchoolLeaderboardPage({super.key});

  @override
  State<SchoolLeaderboardPage> createState() => _SchoolLeaderboardPageState();
}

class _SchoolLeaderboardPageState extends State<SchoolLeaderboardPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _schools = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiClient.dio.get('/Schools/leaderboard');
      final raw = response.data is Map ? response.data['data'] ?? response.data : response.data;
      setState(() {
        _schools = raw as List<dynamic>? ?? const [];
        _loading = false;
      });
    } on DioException catch (error) {
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ErrorState(title: l10n.errorTitle, subtitle: _error)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: l10n.schoolTitle, subtitle: l10n.schoolSubtitle),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _schools.isEmpty
                              ? EmptyState(
                                  title: l10n.emptyTitle,
                                  subtitle: l10n.emptySubtitle,
                                  icon: Icons.school_outlined,
                                )
                              : ListView.separated(
                                  itemBuilder: (context, index) {
                                    final school = _schools[index] as Map<dynamic, dynamic>;
                                    return GlassCard(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          CircleAvatar(child: Text('${index + 1}')),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              school['name']?.toString() ?? '-',
                                              style: Theme.of(context).textTheme.bodyLarge,
                                            ),
                                          ),
                                          Text(
                                            '${school['averageXP'] ?? school['xp'] ?? 0}',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemCount: _schools.length,
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
