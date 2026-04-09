import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class ReferralStudentPage extends StatefulWidget {
  const ReferralStudentPage({super.key});

  @override
  State<ReferralStudentPage> createState() => _ReferralStudentPageState();
}

class _ReferralStudentPageState extends State<ReferralStudentPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiClient.dio.get('/referral/me');
      final raw = response.data is Map ? response.data['data'] ?? response.data : response.data;
      setState(() {
        _data = raw is Map ? Map<String, dynamic>.from(raw) : null;
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
    final code = _data?['myCode']?.toString() ?? _data?['referralCode']?.toString() ?? '-';
    final friends = (_data?['friends'] as List<dynamic>? ?? const []);

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
                        SectionHeader(title: l10n.referralTitle, subtitle: l10n.referralSubtitle),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Referral code', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              Text(code, style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 16),
                              AppSecondaryButton(
                                label: l10n.commonShare,
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: code));
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.commonCopied)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: friends.isEmpty
                              ? EmptyState(
                                  title: l10n.emptyTitle,
                                  subtitle: l10n.emptySubtitle,
                                  icon: Icons.people_outline_rounded,
                                )
                              : ListView.separated(
                                  itemBuilder: (context, index) {
                                    final item = friends[index] as Map<dynamic, dynamic>;
                                    return GlassCard(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          const CircleAvatar(child: Icon(Icons.person_rounded)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              item['fullName']?.toString() ?? 'User',
                                              style: Theme.of(context).textTheme.bodyLarge,
                                            ),
                                          ),
                                          Text(
                                            item['status']?.toString() ?? '-',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemCount: friends.length,
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
