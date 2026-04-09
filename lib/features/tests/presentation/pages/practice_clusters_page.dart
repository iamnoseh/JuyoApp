import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class PracticeClustersPage extends StatefulWidget {
  const PracticeClustersPage({super.key});

  @override
  State<PracticeClustersPage> createState() => _PracticeClustersPageState();
}

class _PracticeClustersPageState extends State<PracticeClustersPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _clusters = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiClient.dio.get('/clusters');
      final raw = response.data is Map ? response.data['data'] ?? response.data : response.data;
      setState(() {
        _clusters = raw as List<dynamic>? ?? const [];
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
                        SectionHeader(title: l10n.commonPractice, subtitle: l10n.testsSubtitle),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _clusters.isEmpty
                              ? EmptyState(title: l10n.emptyTitle, subtitle: l10n.emptySubtitle)
                              : ListView.separated(
                                  itemBuilder: (context, index) {
                                    final cluster = _clusters[index] as Map<dynamic, dynamic>;
                                    return GlassCard(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.layers_outlined, color: Colors.white),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              cluster['name']?.toString() ?? '-',
                                              style: Theme.of(context).textTheme.bodyLarge,
                                            ),
                                          ),
                                          AppSecondaryButton(
                                            label: 'Start',
                                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(l10n.commonSoon)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemCount: _clusters.length,
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
