import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juyo/core/constants/app_constants.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/app_ui.dart';
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

  const ProfileEditPage({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  static const List<String> _provinces = [
    'Душанбе',
    'ГБАО',
    'Согдийская область',
    'Хатлонская область',
    'РРП',
  ];

  static const List<_ClusterOption> _clusters = [
    _ClusterOption(1, 'Естественные и технические науки'),
    _ClusterOption(2, 'Экономика и география'),
    _ClusterOption(3, 'Филология, педагогика и искусство'),
    _ClusterOption(4, 'Обществознание и право'),
    _ClusterOption(5, 'Медицина, биология и спорт'),
  ];

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final ImagePicker _picker = ImagePicker();

  String? _province;
  int? _gender;
  int? _schoolId;
  int? _grade;
  int? _clusterId;
  int? _targetUniversityId;
  int? _targetMajorId;
  DateTime? _dateOfBirth;
  File? _avatarFile;

  List<SchoolEntity> _schools = const [];
  List<UniversityEntity> _universities = const [];
  List<MajorEntity> _majors = const [];
  bool _isLoadingReferences = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _province = widget.profile.province;
    _gender = widget.profile.gender;
    _schoolId = widget.profile.schoolId;
    _grade = widget.profile.grade;
    _clusterId = widget.profile.clusterId;
    _targetUniversityId = widget.profile.targetUniversityId;
    _targetMajorId = widget.profile.targetMajorId;
    _dateOfBirth = _tryParseDate(widget.profile.dateOfBirth);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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
          listener: (context, state) {
            if (state is ReferenceLoading) {
              setState(() => _isLoadingReferences = true);
              return;
            }

            if (state is ReferenceFailure) {
              setState(() => _isLoadingReferences = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              return;
            }

            if (state is! ReferenceLoaded) return;

            final filteredSchoolIds = state.schools
                .where(
                  (school) =>
                      _province == null ||
                      _province!.isEmpty ||
                      school.province == _province,
                )
                .map((school) => school.id)
                .toSet();

            final universityIds = state.universities.map((item) => item.id).toSet();
            final majorIds = state.majors.map((item) => item.id).toSet();

            setState(() {
              _schools = state.schools;
              _universities = state.universities;
              _majors = state.majors;
              _schoolId = filteredSchoolIds.contains(_schoolId) ? _schoolId : null;
              _targetUniversityId =
                  universityIds.contains(_targetUniversityId) ? _targetUniversityId : null;
              _targetMajorId = majorIds.contains(_targetMajorId) ? _targetMajorId : null;
              _isLoadingReferences = false;
            });
          },
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final isSaving = state is ProfileSaving;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    AppTopStatsBar(
                      totalXp: widget.profile.xp,
                      streak: widget.profile.streak,
                    ),
                    const SizedBox(height: 16),
                    _EditHeader(
                      title: _tr(context, 'Редактирование профиля', 'Edit profile'),
                      onClose: () => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoadingReferences
                          ? const Center(
                              child: CircularProgressIndicator(color: AppColors.aqua),
                            )
                          : ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _AvatarCard(
                                  imageProvider: _buildAvatarProvider(),
                                  initials: _initials(widget.profile.fullName),
                                  onPickAvatar: _pickAvatar,
                                ),
                                const SizedBox(height: 12),
                                GlassCard(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    children: [
                                      _CompactTextField(
                                        label: _tr(context, 'Имя', 'First name'),
                                        controller: _firstNameController,
                                        icon: LucideIcons.user,
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactTextField(
                                        label: _tr(context, 'Фамилия', 'Last name'),
                                        controller: _lastNameController,
                                        icon: LucideIcons.userCheck,
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactPickerField<String>(
                                        label: _tr(context, 'Область', 'Province'),
                                        value: _province,
                                        displayText: _province,
                                        icon: LucideIcons.mapPin,
                                        searchable: true,
                                        onTap: () async {
                                          final result = await _showPickerSheet<String>(
                                            context,
                                            title: _tr(context, 'Выберите область', 'Choose province'),
                                            options: _provinces,
                                            selected: _province,
                                            labelBuilder: (item) => item,
                                          );
                                          if (result == null || !mounted) return;
                                          setState(() {
                                            _province = result;
                                            _schoolId = null;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactPickerField<int>(
                                        label: _tr(context, 'Пол', 'Gender'),
                                        value: _gender,
                                        displayText: _gender == null
                                            ? null
                                            : (_gender == 0
                                                ? _tr(context, 'Мужской', 'Male')
                                                : _tr(context, 'Женский', 'Female')),
                                        icon: LucideIcons.user,
                                        onTap: () async {
                                          final result = await _showPickerSheet<int>(
                                            context,
                                            title: _tr(context, 'Выберите пол', 'Choose gender'),
                                            options: const [0, 1],
                                            selected: _gender,
                                            labelBuilder: (item) => item == 0
                                                ? _tr(context, 'Мужской', 'Male')
                                                : _tr(context, 'Женский', 'Female'),
                                          );
                                          if (!mounted) return;
                                          setState(() => _gender = result);
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactDateField(
                                        label: _tr(context, 'Дата рождения', 'Date of birth'),
                                        value: _dateOfBirth == null
                                            ? null
                                            : _humanDate(_dateOfBirth!, context),
                                        onTap: _pickDateOfBirth,
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactPickerField<int>(
                                        label: _tr(context, 'Школа', 'School'),
                                        value: _schoolId,
                                        displayText: _selectedSchoolName,
                                        icon: LucideIcons.school,
                                        searchable: true,
                                        onTap: () async {
                                          final options = _filteredSchools;
                                          if (options.isEmpty) return;
                                          final result = await _showPickerSheet<SchoolEntity>(
                                            context,
                                            title: _tr(context, 'Выберите школу', 'Choose school'),
                                            options: options,
                                            selected: options.cast<SchoolEntity?>().firstWhere(
                                                  (item) => item?.id == _schoolId,
                                                  orElse: () => null,
                                                ),
                                            labelBuilder: (item) => item.name,
                                          );
                                          if (result == null || !mounted) return;
                                          setState(() => _schoolId = result.id);
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactPickerField<int>(
                                        label: _tr(context, 'Класс', 'Grade'),
                                        value: _grade,
                                        displayText: _grade == null
                                            ? null
                                            : _tr(context, '$_grade класс', 'Grade $_grade'),
                                        icon: LucideIcons.graduationCap,
                                        onTap: () async {
                                          final result = await _showPickerSheet<int>(
                                            context,
                                            title: _tr(context, 'Выберите класс', 'Choose grade'),
                                            options: List<int>.generate(11, (index) => index + 1),
                                            selected: _grade,
                                            labelBuilder: (item) =>
                                                _tr(context, '$item класс', 'Grade $item'),
                                          );
                                          if (!mounted) return;
                                          setState(() => _grade = result);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GlassCard(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _SectionBanner(
                                        title: _tr(
                                          context,
                                          'Твои академические цели',
                                          'Your academic goals',
                                        ),
                                        subtitle: _tr(
                                          context,
                                          'Настрой профиль под свою цель поступления.',
                                          'Set up your profile around your admission goal.',
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactPickerField<int>(
                                        label: _tr(context, 'Мой кластер', 'My cluster'),
                                        value: _clusterId,
                                        displayText: _selectedClusterName,
                                        icon: LucideIcons.sparkles,
                                        searchable: true,
                                        enabled: widget.profile.clusterId == null,
                                        helperText: widget.profile.clusterId != null
                                            ? _tr(
                                                context,
                                                'Кластер нельзя изменить после выбора',
                                                'Cluster cannot be changed after selection',
                                              )
                                            : null,
                                        onTap: widget.profile.clusterId != null
                                            ? null
                                            : () async {
                                                final result =
                                                    await _showPickerSheet<_ClusterOption>(
                                                  context,
                                                  title: _tr(
                                                    context,
                                                    'Выберите кластер',
                                                    'Choose cluster',
                                                  ),
                                                  options: _clusters,
                                                  selected: _clusters.cast<_ClusterOption?>().firstWhere(
                                                        (item) => item?.id == _clusterId,
                                                        orElse: () => null,
                                                      ),
                                                  labelBuilder: (item) => item.name,
                                                );
                                                if (result == null || !mounted) return;
                                                setState(() => _clusterId = result.id);
                                              },
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactPickerField<int>(
                                        label: _tr(context, 'Университет мечты', 'Dream university'),
                                        value: _targetUniversityId,
                                        displayText: _selectedUniversityName,
                                        icon: LucideIcons.building2,
                                        searchable: true,
                                        onTap: () async {
                                          if (_universities.isEmpty) return;
                                          final result =
                                              await _showPickerSheet<UniversityEntity>(
                                            context,
                                            title: _tr(
                                              context,
                                              'Выберите университет',
                                              'Choose university',
                                            ),
                                            options: _universities,
                                            selected: _universities.cast<UniversityEntity?>().firstWhere(
                                                  (item) => item?.id == _targetUniversityId,
                                                  orElse: () => null,
                                                ),
                                            labelBuilder: (item) => item.name,
                                          );
                                          if (result == null || !mounted) return;
                                          setState(() {
                                            _targetUniversityId = result.id;
                                            _targetMajorId = null;
                                            _majors = const [];
                                          });
                                          context
                                              .read<ReferenceBloc>()
                                              .add(ReferenceMajorsRequested(result.id));
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _CompactPickerField<int>(
                                        label: _tr(context, 'Будущая профессия', 'Future major'),
                                        value: _targetMajorId,
                                        displayText: _selectedMajorName,
                                        icon: LucideIcons.target,
                                        searchable: true,
                                        enabled: _targetUniversityId != null,
                                        onTap: _targetUniversityId == null
                                            ? null
                                            : () async {
                                                final result = await _showPickerSheet<MajorEntity>(
                                                  context,
                                                  title: _tr(
                                                    context,
                                                    'Выберите специальность',
                                                    'Choose major',
                                                  ),
                                                  options: _majors,
                                                  selected: _majors.cast<MajorEntity?>().firstWhere(
                                                        (item) => item?.id == _targetMajorId,
                                                        orElse: () => null,
                                                      ),
                                                  labelBuilder: (item) => item.name,
                                                );
                                                if (result == null || !mounted) return;
                                                setState(() => _targetMajorId = result.id);
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppPrimaryButton(
                                  label: _tr(context, 'Сохранить', 'Save'),
                                  isLoading: isSaving,
                                  icon: LucideIcons.save,
                                  onPressed: isSaving
                                      ? null
                                      : () {
                                          _save();
                                        },
                                ),
                                const SizedBox(height: 10),
                                AppSecondaryButton(
                                  label: _tr(context, 'Отмена', 'Cancel'),
                                  onPressed: isSaving
                                      ? null
                                      : () => Navigator.of(context).pop(false),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ImageProvider<Object>? _buildAvatarProvider() {
    if (_avatarFile != null) return FileImage(_avatarFile!);
    final avatarUrl = _resolveAvatarUrl(widget.profile.avatarUrl);
    if (avatarUrl != null) {
      return NetworkImage(avatarUrl);
    }
    return null;
  }

  String? get _selectedSchoolName {
    try {
      return _filteredSchools.firstWhere((school) => school.id == _schoolId).name;
    } catch (_) {
      return null;
    }
  }

  String? get _selectedUniversityName {
    try {
      return _universities.firstWhere((item) => item.id == _targetUniversityId).name;
    } catch (_) {
      return null;
    }
  }

  String? get _selectedMajorName {
    try {
      return _majors.firstWhere((item) => item.id == _targetMajorId).name;
    } catch (_) {
      return null;
    }
  }

  String? get _selectedClusterName {
    try {
      return _clusters.firstWhere((item) => item.id == _clusterId).name;
    } catch (_) {
      return null;
    }
  }

  List<SchoolEntity> get _filteredSchools {
    return _schools
        .where(
          (school) =>
              _province == null || _province!.isEmpty || school.province == _province,
        )
        .toList();
  }

  DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 16, 1, 1),
      firstDate: DateTime(1950, 1, 1),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() => _dateOfBirth = picked);
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
        SnackBar(
          content: Text(
            _tr(context, 'Файл слишком большой. Максимум 10MB', 'File is too large. Max 10MB'),
          ),
        ),
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
              firstName: _firstNameController.text.trim().isEmpty
                  ? null
                  : _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim().isEmpty
                  ? null
                  : _lastNameController.text.trim(),
              gender: _gender,
              province: _province,
              schoolId: _schoolId,
              grade: _grade,
              clusterId: _clusterId,
              targetUniversityId: _targetUniversityId,
              targetMajorId: _targetMajorId,
              dateOfBirth: _dateOfBirth,
              avatar: avatar,
            ),
          ),
        );
  }
}

class _EditHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _EditHeader({
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.86),
          ),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final ImageProvider<Object>? imageProvider;
  final String initials;
  final Future<void> Function() onPickAvatar;

  const _AvatarCard({
    required this.imageProvider,
    required this.initials,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
                    initials,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          AppSecondaryButton(
            label: _tr(context, 'Изменить', 'Change'),
            icon: LucideIcons.camera,
            onPressed: () {
              onPickAvatar();
            },
          ),
        ],
      ),
    );
  }
}

class _SectionBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionBanner({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.aqua.withValues(alpha: 0.12),
            AppColors.aqua.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  color: AppColors.aqua,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CompactTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  const _CompactTextField({
    required this.label,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: controller,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Icon(icon, size: 17, color: AppColors.textSecondary),
              filled: true,
              fillColor: palette.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactDateField extends StatelessWidget {
  final String label;
  final String? value;
  final Future<void> Function() onTap;

  const _CompactDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _CompactPickerField<String>(
      label: label,
      value: value,
      displayText: value,
      icon: LucideIcons.calendar,
      onTap: () {
        onTap();
      },
    );
  }
}

class _CompactPickerField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String? displayText;
  final IconData icon;
  final bool enabled;
  final bool searchable;
  final String? helperText;
  final VoidCallback? onTap;

  const _CompactPickerField({
    required this.label,
    required this.value,
    required this.displayText,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.searchable = false,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final textColor = enabled
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).textTheme.bodySmall?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: enabled ? onTap : null,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: enabled ? palette.inputFill : palette.inputFill.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 17, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayText ?? label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: displayText == null ? AppColors.textSecondary : textColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (searchable)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.search_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled ? AppColors.textSecondary : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.gold,
                ),
          ),
        ],
      ],
    );
  }
}

class _PickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T item) labelBuilder;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelBuilder,
  });

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final filtered = widget.options.where((item) {
      final label = widget.labelBuilder(item).toLowerCase();
      return label.contains(_query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: _tr(context, 'Поиск...', 'Search...'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final selected = item == widget.selected;

                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () => Navigator.of(context).pop(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: selected
                              ? [
                                  AppColors.gold.withValues(alpha: 0.16),
                                  AppColors.gold.withValues(alpha: 0.08),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.white.withValues(alpha: 0.03),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.labelBuilder(item),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                                    color: selected ? AppColors.gold : null,
                                  ),
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClusterOption {
  final int id;
  final String name;

  const _ClusterOption(this.id, this.name);
}

Future<T?> _showPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T? selected,
  required String Function(T item) labelBuilder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.78,
      child: _PickerSheet<T>(
        title: title,
        options: options,
        selected: selected,
        labelBuilder: labelBuilder,
      ),
    ),
  );
}

String _tr(BuildContext context, String ru, String en) =>
    Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

String _humanDate(DateTime date, BuildContext context) {
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

  final months =
      Localizations.localeOf(context).languageCode == 'ru' ? ruMonths : enMonths;
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _initials(String name) {
  final parts = name
      .split(RegExp(r'\s+'))
      .where((item) => item.isNotEmpty)
      .take(2)
      .map((item) => item.substring(0, 1).toUpperCase())
      .toList();
  return parts.isEmpty ? 'J' : parts.join();
}

String? _resolveAvatarUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;
  final host = AppConstants.apiBaseUrl.replaceFirst('/api', '');
  return rawUrl.startsWith('/') ? '$host$rawUrl' : '$host/$rawUrl';
}
