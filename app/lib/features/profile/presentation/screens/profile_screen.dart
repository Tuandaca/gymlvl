import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/class_providers.dart';
import '../../../onboarding/domain/class_definitions.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  // Controllers cho các trường biometrics
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  // Schedule state
  int _gymDays = 3;
  int _homeDays = 0;
  List<String> _preferredDays = [];
  final List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _populateControllers(Map<String, dynamic>? user, Map<String, dynamic>? profile) {
    _nameController.text = user?['display_name'] ?? '';
    _ageController.text = (profile?['age'] ?? '').toString();
    _heightController.text = (profile?['height_cm'] ?? '').toString();
    _weightController.text = (profile?['weight_kg'] ?? '').toString();
    
    _gymDays = profile?['weekly_gym_days'] ?? 3;
    _homeDays = profile?['weekly_home_days'] ?? 0;
    _preferredDays = List<String>.from(profile?['preferred_training_days'] ?? []);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Chưa đăng nhập');

      // Update users table
      await SupabaseConfig.client.from('users').update({
        'display_name': _nameController.text.trim(),
      }).eq('id', userId);

      // Update profiles table
      final age = int.tryParse(_ageController.text);
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);

      await SupabaseConfig.client.from('profiles').update({
        if (age != null) 'age': age,
        if (height != null) 'height_cm': height,
        if (weight != null) 'weight_kg': weight,
        'weekly_gym_days': _gymDays,
        'weekly_home_days': _homeDays,
        'preferred_training_days': _preferredDays,
      }).eq('id', userId);

      // Refresh providers
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentUserProfileProvider);

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã cập nhật hồ sơ lưu trữ!'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: AppTheme.dangerOrange),
        );
      }
    }
  }

  // ============== CLASS SWITCH MODAL ==============
  void _showClassPickerSheet(String slot, String currentClassId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.panelBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.cyanNeon.withOpacity(0.5), width: 2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHỌN ${slot.toUpperCase()} CLASS',
                    style: const TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.cyanNeon),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'RETROSPECTIVE LEVELING: Hệ thống sẽ đánh giá lại lịch sử tập luyện của bạn để tính toán Level phù hợp cho Class mới thay vì quay về Level 1.',
                style: TextStyle(color: AppTheme.textDim, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: kClassDefinitions.length,
                  itemBuilder: (context, index) {
                    final classId = kClassDefinitions.keys.elementAt(index);
                    final classDef = kClassDefinitions[classId]!;
                    final isSelected = currentClassId == classId;
                    final color = Color(classDef.colorHex);

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _switchClass(classId, slot);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : Colors.black26,
                          border: Border.all(color: isSelected ? color : Colors.white12, width: isSelected ? 2 : 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(classDef.iconEmoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    classDef.className,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color, fontFamily: 'Orbitron'),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(classDef.focus, style: const TextStyle(color: AppTheme.textDim, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: color)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _switchClass(String classId, String slot) async {
    // Check if loading or similar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        shape: RoundedRectangleBorder(side: BorderSide(color: AppTheme.cyanNeon.withOpacity(0.5)), borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận Đổi Class?', style: TextStyle(fontFamily: 'Orbitron', color: AppTheme.cyanNeon, fontSize: 16)),
        content: const Text('Hệ thống sẽ đồng bộ lịch sử tập luyện của bạn chuyên về nhóm cơ này vào Class mới.', style: TextStyle(color: AppTheme.textMain)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy', style: TextStyle(color: AppTheme.textDim))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đồng ý', style: TextStyle(color: AppTheme.cyanNeon))),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        await ref.read(classControllerProvider.notifier).switchClass(newClassId: classId, slot: slot);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Đã đổi Class thành công!'), backgroundColor: AppTheme.successGreen));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.dangerOrange));
        }
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppTheme.dangerOrange.withOpacity(0.5))),
        title: const Text('Đăng xuất?', style: TextStyle(fontFamily: 'Orbitron', color: AppTheme.dangerOrange, fontSize: 16)),
        content: const Text('Bạn có chắc muốn thoát tài khoản hiện tại?', style: TextStyle(color: AppTheme.textMain)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy', style: TextStyle(color: AppTheme.textDim))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Đăng xuất', style: TextStyle(color: AppTheme.dangerOrange))),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(currentUserProvider);
    final profileState = ref.watch(currentUserProfileProvider);
    final classesState = ref.watch(userClassesProvider);
    final classControllerState = ref.watch(classControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('HỆ THỐNG NHÂN VẬT', style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppTheme.cyanNeon),
              onPressed: () {
                final user = userState.value;
                final profile = profileState.value;
                _populateControllers(user, profile);
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: userState.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Không tìm thấy dữ liệu', style: TextStyle(color: AppTheme.textDim)));
          final profile = profileState.value;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(user),
                    const SizedBox(height: 28),

                    _buildSectionHeader('BIOMETRICS BOARD'),
                    const SizedBox(height: 12),
                    _isEditing ? _buildBiometricsEdit() : _buildBiometricsReadonly(profile),
                    const SizedBox(height: 28),

                    _buildSectionHeader('BATTLE SCHEDULE'),
                    const SizedBox(height: 12),
                    _isEditing ? _buildScheduleEdit() : _buildScheduleReadonly(profile),
                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('ACTIVE CLASSES'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildClassesSection(classesState),
                    const SizedBox(height: 28),

                    if (_isEditing) _buildEditActions(),
                    if (!_isEditing) _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              if (classControllerState.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator(color: AppTheme.cyanNeon)),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.cyanNeon)),
        error: (e, _) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppTheme.cyanNeon, boxShadow: [BoxShadow(color: AppTheme.cyanNeon, blurRadius: 4)])),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13)),
      ],
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> user) {
    final level = (user['level'] as num?)?.toInt() ?? 1;
    final title = (user['current_title'] as String?) ?? 'Seeker';
    final displayName = user['display_name'] ?? 'User';
    final email = SupabaseConfig.client.auth.currentUser?.email ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground,
        border: Border(left: BorderSide(color: AppTheme.cyanNeon, width: 4)),
        boxShadow: [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.purpleNeon, width: 2),
              boxShadow: [BoxShadow(color: AppTheme.purpleNeon.withOpacity(0.3), blurRadius: 12)],
            ),
            child: Center(child: Text('Lv$level', style: const TextStyle(fontFamily: 'Orbitron', color: AppTheme.cyanNeon, fontWeight: FontWeight.bold, fontSize: 14))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing)
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.cyanNeon)), isDense: true, contentPadding: EdgeInsets.only(bottom: 4)),
                  )
                else
                  Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(title.toUpperCase(), style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(color: AppTheme.textDim.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricsReadonly(Map<String, dynamic>? profile) {
    final age = profile?['age'];
    final height = profile?['height_cm'];
    final weight = profile?['weight_kg'];

    return Row(
      children: [
        _buildHudBox('TUỔI', age != null ? '$age' : '-'),
        const SizedBox(width: 10),
        _buildHudBox('CAO', height != null ? '${height}cm' : '-'),
        const SizedBox(width: 10),
        _buildHudBox('NẶNG', weight != null ? '${weight}kg' : '-'),
      ],
    );
  }

  Widget _buildHudBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black26,
          //border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: AppTheme.cyanNeon, fontFamily: 'Orbitron', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppTheme.textDim, fontSize: 10, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricsEdit() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _editField('Tuổi', _ageController, TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _editField('Cao (cm)', _heightController, TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _editField('Nặng (kg)', _weightController, TextInputType.number)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppTheme.cyanNeon, fontFamily: 'Orbitron', fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textDim, fontSize: 12),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppTheme.cyanNeon), borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildScheduleReadonly(Map<String, dynamic>? profile) {
    final gymDays = profile?['weekly_gym_days'] ?? 3;
    final homeDays = profile?['weekly_home_days'] ?? 0;
    final preferredDays = (profile?['preferred_training_days'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.purpleNeon.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GYM/HOME RATIO', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
              Text('$gymDays/$homeDays DAYS', style: const TextStyle(color: Colors.white, fontFamily: 'Orbitron', fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('PREFERRED PROTOCOLS', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: preferredDays.map((d) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.cyanNeon.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.cyanNeon)),
              child: Text(d, style: const TextStyle(color: AppTheme.cyanNeon, fontSize: 11, fontWeight: FontWeight.bold)),
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildScheduleEdit() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.panelBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.purpleNeon.withOpacity(0.8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Số buổi tập Gym/tuần: $_gymDays', style: const TextStyle(color: Colors.white, fontSize: 13)),
          Slider(
            value: _gymDays.toDouble(),
            min: 0, max: 7, divisions: 7,
            activeColor: AppTheme.cyanNeon, inactiveColor: Colors.white12,
            onChanged: (val) => setState(() => _gymDays = val.toInt()),
          ),
          const SizedBox(height: 10),
          Text('Số buổi tự tập ở nhà/tuần: $_homeDays', style: const TextStyle(color: Colors.white, fontSize: 13)),
          Slider(
            value: _homeDays.toDouble(),
            min: 0, max: 7, divisions: 7,
            activeColor: AppTheme.purpleNeon, inactiveColor: Colors.white12,
            onChanged: (val) => setState(() => _homeDays = val.toInt()),
          ),
          const SizedBox(height: 16),
          const Text('Ngày rảnh tập:', style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _weekDays.map((day) {
              final isSelected = _preferredDays.contains(day);
              return FilterChip(
                label: Text(day, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12)),
                selected: isSelected,
                selectedColor: AppTheme.cyanNeon,
                backgroundColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: isSelected ? AppTheme.cyanNeon : Colors.white24)),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) _preferredDays.add(day);
                    else _preferredDays.remove(day);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesSection(AsyncValue<List<Map<String, dynamic>>> classesState) {
    return classesState.when(
      data: (classes) {
        final primary = classes.firstWhere((c) => c['slot'] == 'primary', orElse: () => {});
        final secondary = classes.firstWhere((c) => c['slot'] == 'secondary', orElse: () => {});

        return Column(
          children: [
            _buildClassHoloCard(primary, 'primary'),
            const SizedBox(height: 12),
            _buildClassHoloCard(secondary, 'secondary'),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.cyanNeon)),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildClassHoloCard(Map<String, dynamic> uc, String slot) {
    final classId = uc['class_id'] as String?;
    if (classId == null) {
      return GestureDetector(
        onTap: () => _showClassPickerSheet(slot, ''),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.white24, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text('+ CHỌN $slot CLASS', style: const TextStyle(color: AppTheme.textDim, fontFamily: 'Orbitron', letterSpacing: 1))),
        ),
      );
    }

    final classDef = kClassDefinitions[classId];
    final level = (uc['level'] as num?)?.toInt() ?? 1;
    final isGraduated = (uc['is_graduated'] as bool?) ?? false;
    final color = classDef != null ? Color(classDef.colorHex) : AppTheme.cyanNeon;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showClassPickerSheet(slot, classId),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(classDef?.iconEmoji ?? '⚔️', style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(classDef?.className.toUpperCase() ?? '', style: TextStyle(color: color, fontFamily: 'Orbitron', fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 8),
                          if (isGraduated) const Text('🎓', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${slot.toUpperCase()} · Lv $level', style: const TextStyle(color: AppTheme.textDim, fontSize: 11, letterSpacing: 1)),
                    ],
                  ),
                ),
                Icon(Icons.swap_horiz, color: AppTheme.textDim.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _isEditing = false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textDim, side: const BorderSide(color: AppTheme.textDim),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('HỦY', style: TextStyle(fontFamily: 'Orbitron', fontSize: 12, letterSpacing: 1)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyanNeon, foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('LƯU', style: TextStyle(fontFamily: 'Orbitron', fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('ĐĂNG XUẤT', style: TextStyle(fontFamily: 'Orbitron', fontSize: 12, letterSpacing: 1)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.dangerOrange,
          side: BorderSide(color: AppTheme.dangerOrange.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
