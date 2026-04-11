import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juyo/core/constants/app_constants.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:juyo/features/premium/presentation/pages/premium_scanner_page.dart';

class PremiumStudentPage extends StatefulWidget {
  const PremiumStudentPage({super.key});

  @override
  State<PremiumStudentPage> createState() => _PremiumStudentPageState();
}

enum _PremiumStep { plans, qr, upload, done }

class _PremiumStudentPageState extends State<PremiumStudentPage> {
  static const List<int> _durationOptions = [1, 2, 3, 6, 12];

  bool _loading = true;
  bool _submitting = false;
  String? _error;

  List<_SubscriptionPlan> _plans = const [];
  _SubscriptionPlan? _activeSubscription;
  bool _hasPending = false;

  _PremiumStep _step = _PremiumStep.plans;
  _SubscriptionPlan? _selectedPlan;
  int _selectedMonths = 1;
  XFile? _receipt;
  String? _scannedCode;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plansResponse = await ApiClient.dio.get('/payment/plans');
      final plansBody = plansResponse.data;
      final plansData = plansBody is Map ? (plansBody['data'] ?? plansBody) : plansBody;
      final plans = (plansData as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => _SubscriptionPlan.fromMap(Map<dynamic, dynamic>.from(item)))
          .toList();

      _SubscriptionPlan? activeSubscription;
      try {
        final subResponse = await ApiClient.dio.get('/payment/my-subscription');
        final subBody = subResponse.data;
        final subData = subBody is Map ? (subBody['data'] ?? subBody) : subBody;
        if (subData is Map) {
          activeSubscription =
              _SubscriptionPlan.fromMap(Map<dynamic, dynamic>.from(subData));
        }
      } on DioException catch (error) {
        final code = error.response?.statusCode ?? 0;
        if (code != 404) rethrow;
      }

      if (!mounted) return;
      setState(() {
        _plans = plans;
        _activeSubscription = activeSubscription;
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.response?.data is Map
            ? (error.response?.data['message']?.toString() ?? error.message)
            : error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _pickPlan(_SubscriptionPlan plan) {
    setState(() {
      _selectedPlan = plan;
      _selectedMonths = plan.durationMonths.clamp(1, 12).toInt();
      _step = _PremiumStep.qr;
      _receipt = null;
      _scannedCode = null;
    });
  }

  Future<void> _openReceiptSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReceiptSourceSheet(
        onSelect: (value) => Navigator.of(context).pop(value),
      ),
    );
    if (source == null) return;
    await _pickReceipt(source);
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2200,
    );
    if (file == null) return;

    final length = await file.length();
    const maxBytes = 10 * 1024 * 1024;
    if (length > maxBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              'Файли чек аз 10MB зиёд аст',
              'Receipt image must be smaller than 10MB',
            ),
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _receipt = file);
  }

  Future<void> _scanCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const PremiumScannerPage()),
    );
    if (!mounted || result == null || result.trim().isEmpty) return;

    final code = result.trim();
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;

    setState(() => _scannedCode = code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tr(
            context,
            'Код скан шуд ва ба clipboard нусха гардид',
            'Code scanned and copied to clipboard',
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final plan = _selectedPlan;
    final receipt = _receipt;
    if (plan == null || receipt == null) return;

    setState(() => _submitting = true);
    try {
      final formData = FormData.fromMap({
        'planId': plan.id,
        'durationMonths': _selectedMonths,
        'receiptImage': await MultipartFile.fromFile(
          receipt.path,
          filename: receipt.name,
        ),
      });

      await ApiClient.dio.post(
        '/payment/submit',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (!mounted) return;
      setState(() {
        _hasPending = true;
        _step = _PremiumStep.done;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              context,
              'Чек фиристода шуд. Админ онро месанҷад.',
              'Receipt submitted. Admin will review it shortly.',
            ),
          ),
        ),
      );
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      final message = error.response?.data is Map
          ? (error.response?.data['message']?.toString() ?? error.message)
          : error.message;

      if (!mounted) return;
      if (code == 409) {
        setState(() {
          _hasPending = true;
          _step = _PremiumStep.done;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? context.l10n.errorTitle)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _reset() {
    setState(() {
      _step = _PremiumStep.plans;
      _selectedPlan = null;
      _selectedMonths = 1;
      _receipt = null;
      _scannedCode = null;
    });
  }

  double get _totalPrice => (_selectedPlan?.price ?? 0) * _selectedMonths;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      topBar: const AppTopStatsBar(),
      title: l10n.premiumTitle,
      subtitle: l10n.premiumSubtitle,
      child: _loading
          ? const SizedBox(height: 420, child: JuyoPageLoader())
          : _error != null
              ? ErrorState(
                  title: l10n.errorTitle,
                  subtitle: _error,
                  onRetry: _loadData,
                )
              : _plans.isEmpty
                  ? EmptyState(
                      title: _tr(context, 'Планҳо ҳоло нестанд', 'No plans available'),
                      subtitle: _tr(
                        context,
                        'Баъдтар боз санҷед ё бо админ тамос гиред.',
                        'Please check again later or contact support.',
                      ),
                      icon: Icons.workspace_premium_outlined,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_activeSubscription != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StatusBanner(
                              color: AppColors.emerald,
                              icon: Icons.check_circle_rounded,
                              text: _tr(
                                context,
                                'Шумо аллакай ${_activeSubscription!.name} доред',
                                'You already have ${_activeSubscription!.name}',
                              ),
                            ),
                          ),
                        if (_hasPending && _activeSubscription == null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StatusBanner(
                              color: AppColors.gold,
                              icon: Icons.schedule_rounded,
                              text: _tr(
                                context,
                                'Пардохти шумо дар навбати санҷиш аст',
                                'Your payment is currently under review',
                              ),
                            ),
                          ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: KeyedSubtree(
                            key: ValueKey(_step),
                            child: _buildStep(),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _PremiumStep.plans:
        return _PlansStep(
          plans: _plans,
          onSelect: _pickPlan,
        );
      case _PremiumStep.qr:
        return _QrStep(
          plan: _selectedPlan!,
          selectedMonths: _selectedMonths,
          totalPrice: _totalPrice,
          scannedCode: _scannedCode,
          durationOptions: _durationOptions,
          onSelectMonths: (months) {
            setState(() => _selectedMonths = months);
          },
          onContinue: () => setState(() => _step = _PremiumStep.upload),
          onBack: _reset,
          onScan: _scanCode,
        );
      case _PremiumStep.upload:
        return _UploadStep(
          plan: _selectedPlan!,
          selectedMonths: _selectedMonths,
          totalPrice: _totalPrice,
          receipt: _receipt,
          submitting: _submitting,
          onBack: () => setState(() => _step = _PremiumStep.qr),
          onPickReceipt: _openReceiptSourcePicker,
          onSubmit: _submit,
        );
      case _PremiumStep.done:
        return _DoneStep(onReset: _reset);
    }
  }
}

class _PlansStep extends StatelessWidget {
  final List<_SubscriptionPlan> plans;
  final ValueChanged<_SubscriptionPlan> onSelect;

  const _PlansStep({
    required this.plans,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroCard(),
        const SizedBox(height: 14),
        ...plans.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlanCard(
                  plan: entry.value,
                  featured: entry.key == 1,
                  onTap: () => onSelect(entry.value),
                ),
              ),
            ),
      ],
    );
  }
}

class _QrStep extends StatelessWidget {
  final _SubscriptionPlan plan;
  final int selectedMonths;
  final double totalPrice;
  final String? scannedCode;
  final List<int> durationOptions;
  final ValueChanged<int> onSelectMonths;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onScan;

  const _QrStep({
    required this.plan,
    required this.selectedMonths,
    required this.totalPrice,
    required this.scannedCode,
    required this.durationOptions,
    required this.onSelectMonths,
    required this.onContinue,
    required this.onBack,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr(context, 'Нақшаи интихобшуда', 'Selected plan'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.72),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                plan.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              if (plan.description?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 6),
                Text(
                  plan.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.72),
                      ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: durationOptions
                    .map(
                      (months) => _DurationChip(
                        months: months,
                        selected: months == selectedMonths,
                        onTap: () => onSelectMonths(months),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              _SummaryPill(
                icon: Icons.payments_outlined,
                label: _tr(context, 'Ҳамагӣ', 'Total'),
                value: '${_formatPrice(totalPrice)} TJS',
                color: AppColors.gold,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr(
                  context,
                  'QR-ро скан кунед ё кодро барои пардохт истифода баред',
                  'Scan the QR or use the code to complete payment',
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              _QrPreview(
                imageUrl: _resolveAssetUrl(plan.qrCodeUrl),
                amountLabel: '${_formatPrice(totalPrice)} TJS',
              ),
              const SizedBox(height: 14),
              AppSecondaryButton(
                label: _tr(context, 'Скан кардани QR / Barcode', 'Scan QR / Barcode'),
                icon: Icons.qr_code_scanner_rounded,
                onPressed: onScan,
              ),
              if (scannedCode != null) ...[
                const SizedBox(height: 12),
                _ScannedCodeCard(code: scannedCode!),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: _tr(context, 'Бозгашт', 'Back'),
                      onPressed: onBack,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppPrimaryButton(
                      label: _tr(context, 'Идома', 'Continue'),
                      icon: Icons.arrow_forward_rounded,
                      onPressed: onContinue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UploadStep extends StatelessWidget {
  final _SubscriptionPlan plan;
  final int selectedMonths;
  final double totalPrice;
  final XFile? receipt;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onPickReceipt;
  final VoidCallback onSubmit;

  const _UploadStep({
    required this.plan,
    required this.selectedMonths,
    required this.totalPrice,
    required this.receipt,
    required this.submitting,
    required this.onBack,
    required this.onPickReceipt,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryPill(
                icon: Icons.workspace_premium_rounded,
                label: _tr(context, 'План', 'Plan'),
                value: plan.name,
                color: AppColors.aqua,
              ),
              _SummaryPill(
                icon: Icons.calendar_month_rounded,
                label: _tr(context, 'Мӯҳлат', 'Duration'),
                value: _tr(context, '$selectedMonths моҳ', '$selectedMonths mo'),
                color: AppColors.emerald,
              ),
              _SummaryPill(
                icon: Icons.payments_rounded,
                label: _tr(context, 'Ҳамагӣ', 'Total'),
                value: '${_formatPrice(totalPrice)} TJS',
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ReceiptDropzone(
            receipt: receipt,
            onTap: onPickReceipt,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  label: _tr(context, 'Бозгашт', 'Back'),
                  onPressed: onBack,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppPrimaryButton(
                  label: _tr(context, 'Фиристодан', 'Submit'),
                  icon: Icons.cloud_upload_rounded,
                  isLoading: submitting,
                  onPressed: receipt == null ? null : onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  final VoidCallback onReset;

  const _DoneStep({
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.emerald.withValues(alpha: 0.22),
                  AppColors.aqua.withValues(alpha: 0.12),
                ],
              ),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.24)),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.emerald,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _tr(context, 'Чек фиристода шуд!', 'Receipt submitted!'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _tr(
              context,
              'Администратор пардохтро месанҷад ва баъд Premium фаъол мешавад.',
              'An administrator will review your payment and activate Premium after approval.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 16),
          _ProgressLine(
            icon: Icons.check_circle_rounded,
            color: AppColors.emerald,
            text: _tr(context, 'Чек қабул шуд', 'Receipt received'),
          ),
          const SizedBox(height: 10),
          _ProgressLine(
            icon: Icons.schedule_rounded,
            color: AppColors.gold,
            text: _tr(context, 'Санҷиши админ', 'Admin review'),
          ),
          const SizedBox(height: 10),
          _ProgressLine(
            icon: Icons.workspace_premium_rounded,
            color: AppColors.aqua,
            text: _tr(context, 'Фаъолсозии Premium', 'Premium activation'),
          ),
          const SizedBox(height: 16),
          AppSecondaryButton(
            label: _tr(context, 'Бозгашт ба нақшаҳо', 'Back to plans'),
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 14),
                const SizedBox(width: 6),
                Text(
                  _tr(context, 'Premium дастрасӣ', 'Premium access'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _tr(
              context,
              'Ҳамаи имкониятҳои JUYO-ро кушоед',
              'Unlock the full JUYO experience',
            ),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _tr(
              context,
              'Тестҳои бештар, аналитикаи васеъ ва ҳамаи feature-ҳои баста дар як ҷо.',
              'More tests, deeper analytics, and every locked feature in one place.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeatureChip(
                icon: Icons.menu_book_rounded,
                label: _tr(context, 'Тестҳои бемаҳдуд', 'Unlimited tests'),
              ),
              _FeatureChip(
                icon: Icons.analytics_rounded,
                label: _tr(context, 'Аналитикаи пурра', 'Advanced analytics'),
              ),
              _FeatureChip(
                icon: Icons.local_fire_department_rounded,
                label: _tr(context, 'Red List ва Duel', 'Red List and Duel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _SubscriptionPlan plan;
  final bool featured;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.featured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (featured)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _tr(context, 'Машҳур', 'Popular'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: featured
                        ? [
                            AppColors.gold.withValues(alpha: 0.24),
                            const Color(0xFFF97316).withValues(alpha: 0.12),
                          ]
                        : [
                            AppColors.aqua.withValues(alpha: 0.20),
                            AppColors.aqua.withValues(alpha: 0.08),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (featured ? AppColors.gold : AppColors.aqua)
                        .withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: featured ? AppColors.gold : AppColors.aqua,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    if (plan.description?.trim().isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.68),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatPrice(plan.price)} TJS / ${plan.durationMonths} ${_tr(context, 'моҳ', 'mo')}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 128,
                child: AppPrimaryButton(
                  label: _tr(context, 'Интихоб', 'Choose'),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final int months;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.months,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.gold : Theme.of(context).colorScheme.onSurface;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.14)
              : Colors.white.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.72,
                ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.gold.withValues(alpha: 0.24)
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.10),
          ),
        ),
        child: Text(
          _tr(context, '$months моҳ', '$months mo'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: selected ? 1 : 0.78),
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _QrPreview extends StatelessWidget {
  final String? imageUrl;
  final String amountLabel;

  const _QrPreview({
    required this.imageUrl,
    required this.amountLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _QrPlaceholder(),
                    )
                  : const _QrPlaceholder(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
            ),
            child: Text(
              amountLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.aqua.withValues(alpha: 0.12),
            AppColors.gold.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_rounded,
              size: 62,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.20),
            ),
            const SizedBox(height: 8),
            Text(
              _tr(context, 'QR ҳоло дастрас нест', 'QR will be available soon'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.56),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannedCodeCard extends StatelessWidget {
  final String code;

  const _ScannedCodeCard({
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.aqua.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.aqua.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Коди сканшуда', 'Scanned code'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.aqua,
                ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            code,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDropzone extends StatelessWidget {
  final XFile? receipt;
  final VoidCallback onTap;

  const _ReceiptDropzone({
    required this.receipt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: receipt != null
              ? AppColors.emerald.withValues(alpha: 0.08)
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: receipt != null
                ? AppColors.emerald.withValues(alpha: 0.18)
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.10),
          ),
        ),
        child: receipt != null
            ? Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1.45,
                      child: Image.file(
                        File(receipt!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          receipt!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: onTap,
                        child: Text(_tr(context, 'Иваз кардан', 'Change')),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(
                    Icons.cloud_upload_rounded,
                    size: 42,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _tr(
                      context,
                      'Чеки пардохтро интихоб кунед',
                      'Choose your payment receipt',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tr(
                      context,
                      'JPG ё PNG, то 10MB. Аз gallery ё камера гирифтан мумкин.',
                      'JPG or PNG, up to 10MB. You can choose from gallery or camera.',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.66),
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ReceiptSourceSheet extends StatelessWidget {
  final ValueChanged<ImageSource> onSelect;

  const _ReceiptSourceSheet({
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F172A)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetAction(
              icon: Icons.photo_library_outlined,
              label: _tr(context, 'Gallery', 'Gallery'),
              onTap: () => onSelect(ImageSource.gallery),
            ),
            const SizedBox(height: 10),
            _SheetAction(
              icon: Icons.camera_alt_outlined,
              label: _tr(context, 'Camera', 'Camera'),
              onTap: () => onSelect(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.aqua),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.aqua.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.aqua.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.aqua),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.66),
                      ),
                ),
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _ProgressLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPlan {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int durationMonths;
  final bool isPremium;
  final bool isActive;
  final String? qrCodeUrl;

  const _SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMonths,
    required this.isPremium,
    required this.isActive,
    required this.qrCodeUrl,
  });

  factory _SubscriptionPlan.fromMap(Map<dynamic, dynamic> json) {
    return _SubscriptionPlan(
      id: _readInt(json, const ['id', 'Id']),
      name: _readString(json, const ['name', 'Name'], fallback: 'Premium'),
      description: _readNullableString(json, const ['description', 'Description']),
      price: _readDouble(json, const ['price', 'Price']),
      durationMonths: _readInt(
        json,
        const ['durationMonths', 'DurationMonths'],
        fallback: 1,
      ),
      isPremium: _readBool(json, const ['isPremium', 'IsPremium']),
      isActive: _readBool(json, const ['isActive', 'IsActive']),
      qrCodeUrl: _readNullableString(json, const ['qrCodeUrl', 'QrCodeUrl']),
    );
  }
}

String _tr(BuildContext context, String ru, String en) {
  return Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
}

int _readInt(
  Map<dynamic, dynamic> json,
  List<String> keys, {
  int fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return fallback;
}

double _readDouble(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return 0;
}

bool _readBool(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is bool) return value;
    final normalized = value.toString().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return false;
}

String _readString(
  Map<dynamic, dynamic> json,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String? _readNullableString(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return null;
}

String _formatPrice(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

String? _resolveAssetUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;

  var cleanPath = rawUrl.replaceAll('\\', '/').trim();
  cleanPath = cleanPath.replaceFirst(RegExp(r'^/?wwwroot/', caseSensitive: false), '');
  cleanPath = cleanPath.startsWith('/') ? cleanPath.substring(1) : cleanPath;

  if (cleanPath.startsWith('qrcodes/') ||
      cleanPath.startsWith('receipts/') ||
      cleanPath.startsWith('uploads/')) {
    final encoded = cleanPath.split('/').map(Uri.encodeComponent).join('/');
    return 'https://storage.googleapis.com/iqra-tj/$encoded';
  }

  final host = AppConstants.apiBaseUrl.replaceFirst('/api', '');
  return rawUrl.startsWith('/') ? '$host$rawUrl' : '$host/$rawUrl';
}
