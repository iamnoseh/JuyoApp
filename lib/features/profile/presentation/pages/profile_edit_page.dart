import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:juyo/features/profile/data/models/update_profile_request_model.dart';
import 'package:juyo/features/profile/domain/entities/profile.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_event.dart';
import 'package:juyo/features/profile/presentation/bloc/profile_state.dart';
import 'package:juyo/features/reference/domain/entities/reference_entities.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_bloc.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_event.dart';
import 'package:juyo/features/reference/presentation/bloc/reference_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileEditPage extends StatefulWidget {
  final Profile profile;

  const ProfileEditPage({super.key, required this.profile});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  static const double _topInset = 112;
  static const double _dockHeight = 66;

  static const List<String> _provinces = [
    'Душанбе',
    'ГБАО',
    'Согдийская область',
    'Хатлонская область',
    'РРП',
  ];

  static const List<_ClusterItem> _clusters = [
    _ClusterItem(1, 'Естественные и технические науки'),
    _ClusterItem(2, 'Экономика и география'),
    _ClusterItem(3, 'Филология, педагогика и искусство'),
    _ClusterItem(4, 'Обществознание и право'),
    _ClusterItem(5, 'Медицина, биология и спорт'),
  ];

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;

  String? _province;
  int? _gender;
  int? _schoolId;
  int? _grade;
  int? _clusterId;
  int? _targetUniversityId;
  int? _targetMajorId;
  DateTime? _dob;

  List<SchoolEntity> _schools = const [];
  List<UniversityEntity> _universities = const [];
  List<MajorEntity> _majors = const [];

  bool _loadingRefs = true;
  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.profile.firstName);
    _lastName = TextEditingController(text: widget.profile.lastName);
    _province = widget.profile.province;
    _gender = widget.profile.gender;
    _schoolId = widget.profile.schoolId;
    _grade = widget.profile.grade;
    _clusterId = widget.profile.clusterId;
    _targetUniversityId = widget.profile.targetUniversityId;
    _targetMajorId = widget.profile.targetMajorId;
    _dob = _parseDate(widget.profile.dateOfBirth);

    final referenceBloc = context.read<ReferenceBloc>();
    if (referenceBloc.state is ReferenceInitial) {
      referenceBloc.add(
        ReferenceLoadRequested(
          selectedUniversityId: _targetUniversityId,
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 16, 1, 1),
      firstDate: DateTime(1950, 1, 1),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    if (await file.length() > 10 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файл слишком большой. Максимум 10MB')),
      );
      return;
    }

    setState(() => _avatarFile = file);
  }

  Future<MultipartFile?> _buildAvatarPart() async {
    if (_avatarFile == null) return null;

    final fileName = _avatarFile!.path.split(Platform.pathSeparator).last;
    var subtype = 'jpeg';
    if (fileName.toLowerCase().endsWith('.png')) subtype = 'png';
    if (fileName.toLowerCase().endsWith('.webp')) subtype = 'webp';

    return MultipartFile.fromFile(
      _avatarFile!.path,
      filename: fileName,
      contentType: MediaType('image', subtype),
    );
  }

  Future<void> _save() async {
    final avatar = await _buildAvatarPart();
    if (!mounted) return;

    context.read<ProfileBloc>().add(
          ProfileUpdateRequested(
            UpdateProfileRequestModel(
              firstName: _firstName.text.trim().isEmpty
                  ? null
                  : _firstName.text.trim(),
              lastName: _lastName.text.trim().isEmpty
                  ? null
                  : _lastName.text.trim(),
              gender: _gender,
              province: _province,
              schoolId: _schoolId,
              grade: _grade,
              clusterId: _clusterId,
              targetUniversityId: _targetUniversityId,
              targetMajorId: _targetMajorId,
              dateOfBirth: _dob,
              avatar: avatar,
            ),
          ),
        );
  }

  void _handleReferenceState(ReferenceState state) {
    if (state is ReferenceLoading) {
      setState(() => _loadingRefs = true);
      return;
    }

    if (state is ReferenceFailure) {
      setState(() => _loadingRefs = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      return;
    }

    if (state is! ReferenceLoaded) return;

    final validSchoolIds = state.schools
        .where(
          (school) =>
              _province == null ||
              _province!.isEmpty ||
              school.province == _province,
        )
        .map((school) => school.id)
        .toSet();

    final validUniversityIds =
        state.universities.map((item) => item.id).toSet();
    final validMajorIds = state.majors.map((item) => item.id).toSet();

    setState(() {
      _schools = state.schools;
      _universities = state.universities;
      _majors = state.majors;
      _schoolId = validSchoolIds.contains(_schoolId) ? _schoolId : null;
      _targetUniversityId = validUniversityIds.contains(_targetUniversityId)
          ? _targetUniversityId
          : null;
      _targetMajorId =
          validMajorIds.contains(_targetMajorId) ? _targetMajorId : null;
      _loadingRefs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (_, state) =>
              state is ProfileUpdateSuccess || state is ProfileFailure,
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              Navigator.of(context).pop(true);
            }

            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        BlocListener<ReferenceBloc, ReferenceState>(
          listener: (_, state) => _handleReferenceState(state),
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final isSaving = state is ProfileSaving;
          final avatarUrl = widget.profile.avatarUrl;
          final bottomInset =
              20 + MediaQuery.of(context).padding.bottom + _dockHeight + 16;

          return Scaffold(
            backgroundColor: AppColors.background,
            bottomNavigationBar: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: _EditBottomDock(
                onSelectTab: (index) => Navigator.of(context).pop(index),
              ),
            ),
            body: Stack(
              children: [
                if (_loadingRefs)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.aqua),
                  )
                else
                  ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      _topInset + 8,
                      16,
                      bottomInset,
                    ),
                    children: [
                      _buildInfoBanner(),
                      const SizedBox(height: 14),
                      _buildAvatarSection(avatarUrl),
                      const SizedBox(height: 14),
                      JuyoInput(
                        label: 'Имя',
                        hint: 'Введите имя',
                        icon: LucideIcons.user,
                        controller: _firstName,
                      ),
                      const SizedBox(height: 12),
                      JuyoInput(
                        label: 'Фамилия',
                        hint: 'Введите фамилию',
                        icon: LucideIcons.userCheck,
                        controller: _lastName,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownString(
                        label: 'Область',
                        icon: LucideIcons.mapPin,
                        value: _province,
                        options: _provinces,
                        onChanged: (value) => setState(() {
                          _province = value;
                          _schoolId = null;
                        }),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownInt(
                        label: 'Пол',
                        icon: LucideIcons.user,
                        value: _gender,
                        options: const [0, 1],
                        itemLabel: (value) =>
                            value == 0 ? 'Мужской' : 'Женский',
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownInt(
                        label: 'Школа',
                        icon: LucideIcons.school,
                        value: _schoolId,
                        options: _schools
                            .where(
                              (school) =>
                                  _province == null ||
                                  _province!.isEmpty ||
                                  school.province == _province,
                            )
                            .map((school) => school.id)
                            .toList(),
                        itemLabel: (id) =>
                            _schools.firstWhere((school) => school.id == id).name,
                        onChanged: (value) => setState(() => _schoolId = value),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownInt(
                        label: 'Класс',
                        icon: LucideIcons.graduationCap,
                        value: _grade,
                        options: List.generate(11, (index) => index + 1),
                        onChanged: (value) => setState(() => _grade = value),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownInt(
                        label: 'Кластер',
                        icon: LucideIcons.sparkles,
                        value: _clusterId,
                        options: const [1, 2, 3, 4, 5],
                        itemLabel: (value) =>
                            _clusters.firstWhere((item) => item.id == value).name,
                        onChanged: widget.profile.clusterId != null
                            ? null
                            : (value) => setState(() => _clusterId = value),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownInt(
                        label: 'Университет',
                        icon: LucideIcons.building2,
                        value: _targetUniversityId,
                        options: _universities.map((item) => item.id).toList(),
                        itemLabel: (id) => _universities
                            .firstWhere((item) => item.id == id)
                            .name,
                        onChanged: (universityId) {
                          setState(() {
                            _targetUniversityId = universityId;
                            _targetMajorId = null;
                            _majors = const [];
                          });

                          if (universityId != null) {
                            context
                                .read<ReferenceBloc>()
                                .add(ReferenceMajorsRequested(universityId));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDropdownInt(
                        label: 'Профессия',
                        icon: LucideIcons.target,
                        value: _targetMajorId,
                        options: _majors.map((item) => item.id).toList(),
                        itemLabel: (id) =>
                            _majors.firstWhere((item) => item.id == id).name,
                        onChanged: _targetUniversityId == null
                            ? null
                            : (value) => setState(() => _targetMajorId = value),
                      ),
                      const SizedBox(height: 12),
                      _buildDobTile(),
                      const SizedBox(height: 18),
                      JuyoButton(
                        text: 'СОХРАНИТЬ',
                        isLoading: isSaving,
                        onPressed: isSaving ? null : _save,
                      ),
                      const SizedBox(height: 10),
                      JuyoButton(
                        text: 'ОТМЕНА',
                        isSecondary: true,
                        onPressed: isSaving
                            ? null
                            : () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: JuyoStickyHeader(
                    streak: widget.profile.streak,
                    points: widget.profile.xp,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.info, size: 18, color: AppColors.aqua),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Изменения сохраняются в вашем аккаунте.',
              style: TextStyle(
                color: AppColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String? avatarUrl) {
    final ImageProvider<Object>? provider = _avatarFile != null
        ? FileImage(_avatarFile!)
        : (avatarUrl != null && avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : null);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white12,
            backgroundImage: provider,
            child: (_avatarFile == null &&
                    (avatarUrl == null || avatarUrl.isEmpty))
                ? const Icon(LucideIcons.user, color: Colors.white54)
                : null,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Фото профиля',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'JPG/PNG/WebP, максимум 10MB',
                  style: TextStyle(color: AppColors.slate, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _pickAvatar,
            icon: const Icon(LucideIcons.camera, size: 16),
            label: const Text('Изменить'),
          ),
        ],
      ),
    );
  }

  Widget _buildDobTile() {
    final text = _dob == null
        ? 'Не выбрано'
        : '${_dob!.day.toString().padLeft(2, '0')}.${_dob!.month.toString().padLeft(2, '0')}.${_dob!.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(LucideIcons.calendar, color: AppColors.aqua, size: 18),
        title: const Text(
          'Дата рождения',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          text,
          style: const TextStyle(
            color: AppColors.slate,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: AppColors.slate,
        ),
        onTap: _pickDob,
      ),
    );
  }

  Widget _buildDropdownInt({
    required String label,
    required IconData icon,
    required int? value,
    required List<int> options,
    String Function(int)? itemLabel,
    required ValueChanged<int?>? onChanged,
  }) {
    final safeValue = options.contains(value) ? value : null;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.slate),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: safeValue,
                isExpanded: true,
                isDense: true,
                alignment: Alignment.centerLeft,
                icon: const Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: AppColors.slate,
                ),
                hint: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.slate.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                dropdownColor: Colors.white,
                selectedItemBuilder: (_) => options
                    .map(
                      (item) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          itemLabel?.call(item) ?? item.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                items: options
                    .map(
                      (item) => DropdownMenuItem<int>(
                        value: item,
                        child: Text(
                          itemLabel?.call(item) ?? item.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownString({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = options.contains(value) ? value : null;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.slate),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: safeValue,
                isExpanded: true,
                isDense: true,
                alignment: Alignment.centerLeft,
                icon: const Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: AppColors.slate,
                ),
                hint: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.slate.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                dropdownColor: Colors.white,
                selectedItemBuilder: (_) => options
                    .map(
                      (item) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                items: options
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClusterItem {
  final int id;
  final String name;

  const _ClusterItem(this.id, this.name);
}

class _EditBottomDock extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const _EditBottomDock({
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFF2C3545),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            _DockItem(
              icon: LucideIcons.layoutDashboard,
              label: 'PARAM',
              onTap: () => onSelectTab(0),
            ),
            _DockItem(
              icon: LucideIcons.swords,
              label: 'DUEL',
              onTap: () => onSelectTab(1),
            ),
            _DockCenter(
              onTap: () => onSelectTab(0),
            ),
            _DockItem(
              icon: LucideIcons.brain,
              label: 'TESTS',
              onTap: () => onSelectTab(2),
            ),
            _DockItem(
              icon: LucideIcons.user,
              label: 'PROFILE',
              active: true,
              onTap: () => onSelectTab(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? AppColors.gold : const Color(0xFFAEB8C8),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: active ? AppColors.gold : const Color(0xFFAEB8C8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockCenter extends StatelessWidget {
  final VoidCallback onTap;

  const _DockCenter({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const Icon(
          LucideIcons.layoutGrid,
          color: AppColors.gold,
          size: 22,
        ),
      ),
    );
  }
}
