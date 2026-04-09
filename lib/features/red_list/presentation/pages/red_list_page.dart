import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class RedListStudentPage extends StatefulWidget {
  const RedListStudentPage({super.key});

  @override
  State<RedListStudentPage> createState() => _RedListStudentPageState();
}

class _RedListStudentPageState extends State<RedListStudentPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _questions = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiClient.dio.get('/RedList/dashboard');
      final raw = response.data is Map ? response.data['data'] ?? response.data : response.data;
      final questions = raw is Map ? raw['activeQuestions'] as List<dynamic>? ?? const [] : const [];
      setState(() {
        _questions = questions;
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
                        SectionHeader(title: l10n.redListTitle, subtitle: l10n.redListSubtitle),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _questions.isEmpty
                              ? EmptyState(
                                  title: l10n.emptyTitle,
                                  subtitle: l10n.emptySubtitle,
                                  icon: Icons.local_fire_department_outlined,
                                )
                              : ListView.separated(
                                  itemBuilder: (context, index) {
                                    final item = _questions[index] as Map<dynamic, dynamic>;
                                    return GlassCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['subjectName']?.toString() ?? '-',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item['content']?.toString() ?? '-',
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemCount: _questions.length,
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
