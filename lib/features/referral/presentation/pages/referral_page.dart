import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juyo/core/l10n/l10n.dart';
import 'package:juyo/core/network/api_client.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralStudentPage extends StatefulWidget {
  const ReferralStudentPage({super.key});

  @override
  State<ReferralStudentPage> createState() => _ReferralStudentPageState();
}

class _ReferralStudentPageState extends State<ReferralStudentPage> {
  bool _loading = true;
  bool _copied = false;
  String? _error;
  ReferralInfoModel? _data;

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
      final response = await ApiClient.dio.get('/referral/me');
      final raw = response.data is Map ? response.data['data'] ?? response.data : response.data;

      if (!mounted) return;
      setState(() {
        _data = raw is Map
            ? ReferralInfoModel.fromMap(Map<String, dynamic>.from(raw))
            : const ReferralInfoModel.empty();
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

  Future<void> _copyCode() async {
    final data = _data;
    if (data == null || data.referralCode.trim().isEmpty) return;

    await Clipboard.setData(ClipboardData(text: data.referralCode));
    if (!mounted) return;

    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tr(context, 'Код скопирован', 'Code copied'),
        ),
      ),
    );

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _openWhatsApp() async {
    final data = _data;
    if (data == null) return;

    final message = Uri.encodeComponent(_shareMessage(data));
    final uri = Uri.parse('https://wa.me/?text=$message');
    await _openExternalUri(uri);
  }

  Future<void> _openTelegram() async {
    final data = _data;
    if (data == null) return;

    final url = Uri.encodeComponent(data.shareUrl);
    final text = Uri.encodeComponent(_shareMessage(data));
    final uri = Uri.parse('https://t.me/share/url?url=$url&text=$text');
    await _openExternalUri(uri);
  }

  Future<void> _openExternalUri(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tr(
            context,
            'Не удалось открыть ссылку',
            'Could not open link',
          ),
        ),
      ),
    );
  }

  String _shareMessage(ReferralInfoModel data) {
    return _tr(
      context,
      'Привет! Регистрируйся в JUYO по моему коду ${data.referralCode} и получи бонус XP. Ссылка: ${data.shareUrl}',
      'Hi! Join JUYO with my code ${data.referralCode} and get bonus XP. Link: ${data.shareUrl}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      topBar: const AppTopStatsBar(),
      title: '',
      showHeader: false,
      scrollable: false,
      child: RefreshIndicator(
        color: AppColors.aqua,
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 104),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            _ReferralHeroHeader(
              title: l10n.referralTitle,
              subtitle: l10n.referralSubtitle,
            ),
            const SizedBox(height: 14),
            if (_loading)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.56,
                child: const JuyoPageLoader(),
              )
            else if (_error != null)
              ErrorState(
                title: l10n.errorTitle,
                subtitle: _error,
                onRetry: _loadData,
              )
            else if (_data != null) ...[
              _ReferralHeroCard(
                data: _data!,
                copied: _copied,
                onCopy: _copyCode,
                onWhatsApp: _openWhatsApp,
                onTelegram: _openTelegram,
              ),
              const SizedBox(height: 14),
              _ReferralStatsRow(data: _data!),
              const SizedBox(height: 14),
              _ReferralHistoryCard(data: _data!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReferralHeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ReferralHeroHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.68),
                ),
          ),
        ],
      ),
    );
  }
}

class _ReferralHeroCard extends StatelessWidget {
  final ReferralInfoModel data;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onWhatsApp;
  final VoidCallback onTelegram;

  const _ReferralHeroCard({
    required this.data,
    required this.copied,
    required this.onCopy,
    required this.onWhatsApp,
    required this.onTelegram,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF141B2B),
                    const Color(0xFF0E1522),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.98),
                    const Color(0xFFF8FBFF),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -38,
              right: -32,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tr(context, 'Реферальная программа', 'Referral program'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _tr(
                      context,
                      'Пригласи друга и получи +500 XP',
                      'Invite a friend and earn +500 XP',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tr(
                      context,
                      'Твой друг тоже получит бонус после первого теста. Делитесь кодом и зарабатывайте XP вместе.',
                      'Your friend also gets a bonus after the first test. Share your code and grow XP together.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.72),
                        ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _tr(context, 'ТВОЙ РЕФЕРАЛЬНЫЙ КОД', 'YOUR REFERRAL CODE'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.50),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.referralCode,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 5,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _ReferralActionButton(
                              label: copied
                                  ? _tr(context, 'Скопировано', 'Copied')
                                  : _tr(context, 'Копировать', 'Copy'),
                              icon: copied
                                  ? Icons.check_rounded
                                  : Icons.content_copy_rounded,
                              color: copied ? AppColors.emerald : AppColors.gold,
                              onTap: onCopy,
                            ),
                            _ReferralActionButton(
                              label: 'WhatsApp',
                              icon: Icons.forum_rounded,
                              color: const Color(0xFF25D366),
                              onTap: onWhatsApp,
                            ),
                            _ReferralActionButton(
                              label: 'Telegram',
                              icon: Icons.send_rounded,
                              color: const Color(0xFF0088CC),
                              onTap: onTelegram,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReferralActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralStatsRow extends StatelessWidget {
  final ReferralInfoModel data;

  const _ReferralStatsRow({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ReferralStatCard(
            icon: Icons.people_alt_rounded,
            color: AppColors.aqua,
            value: '${data.totalInvited}',
            label: _tr(context, 'Приглашено друзей', 'Invited friends'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ReferralStatCard(
            icon: Icons.card_giftcard_rounded,
            color: AppColors.gold,
            value: '${data.totalEarnedXp}',
            label: 'XP',
          ),
        ),
      ],
    );
  }
}

class _ReferralStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _ReferralStatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.58),
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

class _ReferralHistoryCard extends StatelessWidget {
  final ReferralInfoModel data;

  const _ReferralHistoryCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.share_rounded, size: 18, color: AppColors.aqua),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _tr(context, 'Мои приглашения', 'My invitations'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data.invitedUsers.isEmpty)
            EmptyState(
              title: _tr(
                context,
                'Пока нет приглашённых друзей',
                'No invited friends yet',
              ),
              subtitle: _tr(
                context,
                'Поделитесь кодом и начните зарабатывать XP вместе.',
                'Share your code and start earning XP together.',
              ),
              icon: Icons.people_outline_rounded,
            )
          else
            Column(
              children: data.invitedUsers
                  .map(
                    (user) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReferralHistoryRow(user: user),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ReferralHistoryRow extends StatelessWidget {
  final InvitedUserModel user;

  const _ReferralHistoryRow({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final completed = user.status.toLowerCase() == 'completed';
    final accent = completed ? AppColors.gold : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.78),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.aqua.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.aqua),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(user.joinedAt, context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.52),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  completed ? Icons.card_giftcard_rounded : Icons.schedule_rounded,
                  size: 14,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Text(
                  completed
                      ? _tr(context, '+500 XP', '+500 XP')
                      : _tr(context, 'Ожидание', 'Pending'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
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

class ReferralInfoModel {
  final String referralCode;
  final String shareUrl;
  final int totalInvited;
  final int completedCount;
  final int totalEarnedXp;
  final List<InvitedUserModel> invitedUsers;

  const ReferralInfoModel({
    required this.referralCode,
    required this.shareUrl,
    required this.totalInvited,
    required this.completedCount,
    required this.totalEarnedXp,
    required this.invitedUsers,
  });

  const ReferralInfoModel.empty()
      : referralCode = '---',
        shareUrl = '',
        totalInvited = 0,
        completedCount = 0,
        totalEarnedXp = 0,
        invitedUsers = const [];

  factory ReferralInfoModel.fromMap(Map<String, dynamic> json) {
    final friendsRaw = json['friends'] ?? json['invitedUsers'] ?? const [];
    final invitedUsers = friendsRaw is List
        ? friendsRaw
            .whereType<Map>()
            .map(
              (item) => InvitedUserModel.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <InvitedUserModel>[];

    final completedCount = _readInt(json, ['completedCount', 'CompletedCount']);

    return ReferralInfoModel(
      referralCode: _readString(
        json,
        ['myCode', 'referralCode', 'MyCode', 'ReferralCode'],
        fallback: '---',
      ),
      shareUrl: _readString(
        json,
        ['shareUrl', 'ShareUrl'],
        fallback: '',
      ),
      totalInvited: _readInt(json, ['totalInvited', 'TotalInvited']),
      completedCount: completedCount,
      totalEarnedXp: _readInt(
        json,
        ['totalEarnedXp', 'totalEarnedXP', 'TotalEarnedXP'],
        fallback: completedCount * 500,
      ),
      invitedUsers: invitedUsers,
    );
  }
}

class InvitedUserModel {
  final String fullName;
  final String status;
  final DateTime? joinedAt;

  const InvitedUserModel({
    required this.fullName,
    required this.status,
    required this.joinedAt,
  });

  factory InvitedUserModel.fromMap(Map<String, dynamic> json) {
    return InvitedUserModel(
      fullName: _readString(
        json,
        ['fullName', 'name', 'Name', 'FullName'],
        fallback: 'User',
      ),
      status: _readString(
        json,
        ['status', 'Status'],
        fallback: 'Pending',
      ),
      joinedAt: DateTime.tryParse(
        _readString(
          json,
          ['joinedAt', 'createdAt', 'JoinedAt', 'CreatedAt'],
          fallback: '',
        ),
      ),
    );
  }
}

String _tr(BuildContext context, String ru, String en) =>
    Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

int _readInt(
  Map<String, dynamic> json,
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

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return fallback;
}

String _formatDate(DateTime? date, BuildContext context) {
  if (date == null) {
    return _tr(context, 'Недавно', 'Recently');
  }

  const ruMonths = [
    'янв',
    'фев',
    'мар',
    'апр',
    'май',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  const enMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final local = date.toLocal();
  final months =
      Localizations.localeOf(context).languageCode == 'ru' ? ruMonths : enMonths;
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
