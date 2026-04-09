import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class LeagueStudentPage extends StatefulWidget {
  const LeagueStudentPage({super.key});

  @override
  State<LeagueStudentPage> createState() => _LeagueStudentPageState();
}

class _LeagueStudentPageState extends State<LeagueStudentPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _leagues = const [];
  List<Map<String, dynamic>> _standings = const [];
  int? _selectedLeagueId;

  @override
  void initState() {
    super.initState();
    _loadLeagues();
  }

  Future<void> _loadLeagues() async {
    try {
      final response = await ApiClient.dio.get('/League');
      final raw = response.data is Map ? response.data['data'] ?? response.data : response.data;
      final leagues = (raw as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      setState(() {
        _leagues = leagues;
        _selectedLeagueId = leagues.isEmpty ? null : (leagues.first['id'] as num?)?.toInt();
      });
      if (_selectedLeagueId != null) {
        await _loadStandings(_selectedLeagueId!);
      } else {
        setState(() => _loading = false);
      }
    } on DioException catch (error) {
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _loadStandings(int leagueId) async {
    try {
      setState(() => _loading = true);
      final response = await ApiClient.dio.get('/League/$leagueId/standings');
      final raw = response.data is Map ? response.data['data'] ?? response.data : response.data;
      final standings = (raw as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      setState(() {
        _standings = standings;
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

    return AppScaffold(
      topBar: const AppTopStatsBar(),
      title: l10n.leagueTitle,
      subtitle: l10n.leagueSubtitle,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(title: l10n.errorTitle, subtitle: _error)
              : Column(
                  children: [
                    if (_leagues.isNotEmpty)
                      SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final league = _leagues[index];
                            final id = (league['id'] as num?)?.toInt();
                            final selected = id == _selectedLeagueId;
                            return ChoiceChip(
                              label: Text(league['name']?.toString() ?? 'League'),
                              selected: selected,
                              onSelected: (_) {
                                if (id == null) return;
                                setState(() => _selectedLeagueId = id);
                                _loadStandings(id);
                              },
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemCount: _leagues.length,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_standings.isEmpty)
                      EmptyState(
                        title: l10n.emptyTitle,
                        subtitle: l10n.emptySubtitle,
                        icon: Icons.emoji_events_outlined,
                      )
                    else
                      ..._standings.take(10).map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GlassCard(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                                      child: Text('${item['rank'] ?? '-'}'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item['userFullName']?.toString() ??
                                            item['name']?.toString() ??
                                            'User',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                    Text(
                                      '${item['weeklyXP'] ?? item['xp'] ?? 0}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
    );
  }
}
