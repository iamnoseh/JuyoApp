import 'dart:io';
import 'package:flutter/material.dart';
import 'package:juyo/core/models/user_model.dart';
import 'package:juyo/core/services/reference_service.dart';
import 'package:juyo/core/services/user_service.dart';
import 'package:juyo/core/theme/app_theme.dart';
import 'package:juyo/core/widgets/juyo_components.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  final UserModel user;

  const ProfileEditPage({super.key, required this.user});

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

  List<SchoolOption> _schools = [];
  List<UniversityOption> _universities = [];
  List<MajorOption> _majors = [];
  bool _loadingRefs = true;
  bool _saving = false;
  final ImagePicker _picker = ImagePicker();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final parts = widget.user.fullName.split(' ').where((p) => p.trim().isNotEmpty).toList();
    _firstName = TextEditingController(text: parts.isNotEmpty ? parts.first : '');
    _lastName = TextEditingController(text: parts.length > 1 ? parts.sublist(1).join(' ') : '');
    _province = widget.user.province;
    _gender = widget.user.gender;
    _schoolId = widget.user.schoolId;
    _grade = widget.user.grade;
    _clusterId = widget.user.clusterId;
    _targetUniversityId = widget.user.targetUniversityId;
    _targetMajorId = widget.user.targetMajorId;
    _dob = _tryParseDate(widget.user.dateOfBirth);
    _loadReferences();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  DateTime? _tryParseDate(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 16, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950, 1, 1),
      lastDate: now,
      helpText: 'Дата рождения',
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _loadReferences() async {
    try {
      final results = await Future.wait([
        ReferenceService.fetchSchools(),
        ReferenceService.fetchUniversities(),
      ]);
      final schools = results[0] as List<SchoolOption>;
      final universities = results[1] as List<UniversityOption>;
      List<MajorOption> majors = [];
      if (_targetUniversityId != null) {
        majors = await ReferenceService.fetchMajors(_targetUniversityId!);
      }
      if (!mounted) return;
      setState(() {
        _schools = schools;
        _universities = universities;
        _majors = majors;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить школы/университеты')),
      );
    } finally {
      if (mounted) setState(() => _loadingRefs = false);
    }
  }

  Future<void> _onUniversityChanged(int? universityId) async {
    setState(() {
      _targetUniversityId = universityId;
      _targetMajorId = null;
      _majors = [];
    });
    if (universityId == null) return;
    try {
      final majors = await ReferenceService.fetchMajors(universityId);
      if (!mounted) return;
      setState(() => _majors = majors);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить специальности')),
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final avatarPart = _avatarFile != null
        ? await UserService.buildAvatarPart(
            _avatarFile!.path,
            _avatarFile!.path.split(Platform.pathSeparator).last,
          )
        : null;
    final ok = await UserService.updateProfile(
      firstName: _firstName.text.trim().isEmpty ? null : _firstName.text.trim(),
      lastName: _lastName.text.trim().isEmpty ? null : _lastName.text.trim(),
      gender: _gender,
      province: _province,
      schoolId: _schoolId,
      grade: _grade,
      clusterId: _clusterId,
      targetUniversityId: _targetUniversityId,
      targetMajorId: _targetMajorId,
      dateOfBirth: _dob,
      avatar: avatarPart,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось сохранить профиль. Попробуйте ещё раз.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.user.profilePictureUrl;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3545),
        foregroundColor: Colors.white,
        title: const Text('Редактировать профиль'),
      ),
      body: _loadingRefs
          ? const Center(child: CircularProgressIndicator(color: AppColors.aqua))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.milkyCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.info, size: 18, color: AppColors.aqua),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Изменения сохраняются в вашем аккаунте.',
                        style: const TextStyle(color: AppColors.slate, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildAvatarSection(avatarUrl),
          const SizedBox(height: 16),
          JuyoInput(label: 'Имя', hint: 'Введите имя', icon: LucideIcons.user, controller: _firstName),
          const SizedBox(height: 12),
          JuyoInput(label: 'Фамилия', hint: 'Введите фамилию', icon: LucideIcons.userCheck, controller: _lastName),
          const SizedBox(height: 12),
          _buildDropdownString(
            label: 'Область',
            icon: LucideIcons.mapPin,
            value: _province,
            options: _provinces,
            onChanged: (v) {
              setState(() {
                _province = v;
                _schoolId = null;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildDropdownInt(
            label: 'Пол',
            icon: LucideIcons.user,
            value: _gender,
            options: const [0, 1],
            itemLabel: (v) => v == 0 ? 'Мужской' : 'Женский',
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 12),
          _buildDropdownInt(
            label: 'Школа',
            icon: LucideIcons.school,
            value: _schoolId,
            options: _schools
                .where((s) => _province == null || _province!.isEmpty || s.province == _province)
                .map((s) => s.id)
                .toList(),
            itemLabel: (id) => _schools.firstWhere((s) => s.id == id).name,
            onChanged: (v) => setState(() => _schoolId = v),
          ),
          const SizedBox(height: 12),
          _buildDropdownInt(
            label: 'Класс',
            icon: LucideIcons.graduationCap,
            value: _grade,
            options: List.generate(11, (i) => i + 1),
            onChanged: (v) => setState(() => _grade = v),
          ),
          const SizedBox(height: 12),
          _buildDropdownInt(
            label: 'Кластер',
            icon: LucideIcons.sparkles,
            value: _clusterId,
            options: const [1, 2, 3, 4, 5],
            itemLabel: (v) => _clusters.firstWhere((c) => c.id == v).name,
            onChanged: widget.user.clusterId != null ? null : (v) => setState(() => _clusterId = v),
          ),
          if (widget.user.clusterId != null) ...[
            const SizedBox(height: 6),
            const Text('Кластер нельзя изменить после выбора', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          _buildDropdownInt(
            label: 'Университет мечты',
            icon: LucideIcons.building2,
            value: _targetUniversityId,
            options: _universities.map((u) => u.id).toList(),
            itemLabel: (id) => _universities.firstWhere((u) => u.id == id).name,
            onChanged: _onUniversityChanged,
          ),
          const SizedBox(height: 12),
          _buildDropdownInt(
            label: 'Будущая профессия',
            icon: LucideIcons.target,
            value: _targetMajorId,
            options: _majors.map((m) => m.id).toList(),
            itemLabel: (id) => _majors.firstWhere((m) => m.id == id).name,
            onChanged: _targetUniversityId == null ? null : (v) => setState(() => _targetMajorId = v),
          ),
          const SizedBox(height: 12),
          _buildDobTile(),
          const SizedBox(height: 18),
          JuyoButton(
            text: 'СОХРАНИТЬ',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
          const SizedBox(height: 10),
          JuyoButton(
            text: 'ОТМЕНА',
            isSecondary: true,
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String? avatarUrl) {
    final ImageProvider? provider = _avatarFile != null
        ? FileImage(_avatarFile!)
        : (avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white12,
            backgroundImage: provider,
            child: (_avatarFile == null && (avatarUrl == null || avatarUrl.isEmpty))
                ? const Icon(LucideIcons.user, color: Colors.white54)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Фото профиля', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  'JPG/PNG/WebP, максимум 10MB',
                  style: const TextStyle(color: AppColors.slate, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _pickAvatar,
            icon: const Icon(LucideIcons.camera, size: 16),
            label: const Text('Изменить'),
          )
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null || !mounted) return;
    final file = File(picked.path);
    final size = await file.length();
    if (size > 10 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файл слишком большой. Максимум 10MB')),
      );
      return;
    }
    setState(() => _avatarFile = file);
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
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(LucideIcons.calendar, color: AppColors.aqua, size: 18),
        title: const Text('Дата рождения', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 13)),
        subtitle: Text(text, style: const TextStyle(color: AppColors.slate, fontSize: 12, fontWeight: FontWeight.w700)),
        trailing: const Icon(LucideIcons.chevronRight, color: AppColors.slate),
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
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.slate),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                hint: Text(label, style: TextStyle(color: AppColors.slate.withValues(alpha: 0.9), fontWeight: FontWeight.w700)),
                dropdownColor: Colors.white,
                iconEnabledColor: AppColors.slate,
                items: options
                    .map((v) => DropdownMenuItem<int>(
                          value: v,
                          child: Text(itemLabel?.call(v) ?? v.toString(), style: const TextStyle(color: AppColors.navy), overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.slate),
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
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.milkyCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.slate),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(label, style: TextStyle(color: AppColors.slate.withValues(alpha: 0.9), fontWeight: FontWeight.w700)),
                dropdownColor: Colors.white,
                iconEnabledColor: AppColors.slate,
                items: options
                    .map((v) => DropdownMenuItem<String>(
                          value: v,
                          child: Text(v, style: const TextStyle(color: AppColors.navy), overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.slate),
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

