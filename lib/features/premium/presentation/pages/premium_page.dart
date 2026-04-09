import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';

class PremiumStudentPage extends StatefulWidget {
  const PremiumStudentPage({super.key});

  @override
  State<PremiumStudentPage> createState() => _PremiumStudentPageState();
}

class _PremiumStudentPageState extends State<PremiumStudentPage> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<Map<String, dynamic>> _plans = const [];
  int? _selectedPlanId;
  XFile? _receipt;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final response = await ApiClient.dio.get('/payment/plans');
      final raw = response.data is Map ? response.data['data'] ?? response.data : response.data;
      final plans = (raw as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      setState(() {
        _plans = plans;
        _selectedPlanId = plans.isEmpty ? null : (plans.first['id'] as num?)?.toInt();
        _loading = false;
      });
    } on DioException catch (error) {
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _pickReceipt() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file == null) return;
    setState(() => _receipt = file);
  }

  Future<void> _submit() async {
    if (_selectedPlanId == null || _receipt == null) return;

    setState(() => _submitting = true);
    try {
      final formData = FormData.fromMap({
        'planId': _selectedPlanId,
        'durationMonths': 1,
        'receiptImage': await MultipartFile.fromFile(
          _receipt!.path,
          filename: _receipt!.name,
        ),
      });
      await ApiClient.dio.post(
        '/payment/submit',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.commonSave)),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? context.l10n.errorTitle)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
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
                        SectionHeader(title: l10n.premiumTitle, subtitle: l10n.premiumSubtitle),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                ..._plans.map(
                                  (plan) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _PlanCard(
                                      selected: _selectedPlanId == (plan['id'] as num?)?.toInt(),
                                      title: plan['name']?.toString() ?? 'Plan',
                                      priceLabel: '${plan['price'] ?? 0} TJS',
                                      onTap: () {
                                        setState(() {
                                          _selectedPlanId = (plan['id'] as num?)?.toInt();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GlassCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Receipt', style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 12),
                                      AppSecondaryButton(
                                        label: _receipt == null ? 'Upload receipt' : _receipt!.name,
                                        onPressed: _pickReceipt,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppPrimaryButton(
                          label: l10n.premiumGoToPlans,
                          isLoading: _submitting,
                          onPressed: _selectedPlanId == null || _receipt == null ? null : _submit,
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String priceLabel;
  final VoidCallback onTap;

  const _PlanCard({
    required this.selected,
    required this.title,
    required this.priceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.gold : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.gold
                    : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.4) ??
                        Colors.white24,
                width: 1.6,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(priceLabel, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
