import 'package:flutter/material.dart';
import '../../../../ui/widgets/status_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/localization/localization_engine.dart';
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
  final List<String> _weekDays = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

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

  void _populateControllers(
    Map<String, dynamic>? user,
    Map<String, dynamic>? profile,
  ) {
    _nameController.text = user?['display_name'] ?? '';
    _ageController.text = (profile?['age'] ?? '').toString();
    _heightController.text = (profile?['height_cm'] ?? '').toString();
    _weightController.text = (profile?['weight_kg'] ?? '').toString();

    _gymDays = profile?['weekly_gym_days'] ?? 3;
    _homeDays = profile?['weekly_home_days'] ?? 0;
    _preferredDays = List<String>.from(
      profile?['preferred_training_days'] ?? [],
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    if (_nameController.text.trim().isEmpty ||
        _nameController.text.trim().length > 80 ||
        age == null ||
        age < 13 ||
        age > 100 ||
        height == null ||
        !height.isFinite ||
        height < 100 ||
        height > 250 ||
        weight == null ||
        !weight.isFinite ||
        weight < 25 ||
        weight > 400 ||
        _gymDays + _homeDays > 7 ||
        _gymDays + _homeDays < 1 ||
        _preferredDays.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('profile_invalid'.tr(ref))));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) throw StateError('No session');
      await SupabaseConfig.client
          .from('users')
          .update({'display_name': _nameController.text.trim()})
          .eq('id', userId);
      await SupabaseConfig.client
          .from('profiles')
          .update({
            'age': age,
            'height_cm': height,
            'weight_kg': weight,
            'weekly_gym_days': _gymDays,
            'weekly_home_days': _homeDays,
            'preferred_training_days': _preferredDays,
          })
          .eq('id', userId);
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentUserProfileProvider);
      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('profile_saved'.tr(ref))));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('request_failed'.tr(ref))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============== CLASS SWITCH MODAL ==============
  void _showClassPickerSheet(
    String slot,
    String currentClassId,
    String? primaryClassId,
  ) {
    List<String> allowedSecondary = [];
    if (slot == 'secondary' && primaryClassId != null) {
      allowedSecondary = getRecommendedSecondary(primaryClassId);
      // Include perfect synergies directly just in case it's missed
      for (final syn in kPerfectSynergies) {
        if (syn.primaryClassId == primaryClassId) {
          allowedSecondary.add(syn.secondaryClassId);
        }
        if (syn.secondaryClassId == primaryClassId) {
          allowedSecondary.add(syn.primaryClassId);
        }
      }
    }

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
            border: Border(
              top: BorderSide(
                color: AppTheme.cyanNeon.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            color: AppTheme.panelBackground,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${'choose_class'.tr(ref)} ${slot.toUpperCase()}",
                    style: const TextStyle(
                      fontFamily: CandyFonts.display,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.cyanNeon,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'retro_leveling_desc'.tr(ref),
                style: const TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              if (slot == 'secondary') ...[
                const SizedBox(height: 10),
                Text(
                  'class_locked_synergy'.tr(ref),
                  style: const TextStyle(
                    color: AppTheme.dangerOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: CandyFonts.display,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: kClassDefinitions.length,
                  itemBuilder: (context, index) {
                    final classId = kClassDefinitions.keys.elementAt(index);
                    final classDef = kClassDefinitions[classId]!;
                    final isSelected = currentClassId == classId;

                    bool isLocked = false;
                    if (slot == 'secondary' && primaryClassId != null) {
                      isLocked =
                          classId == primaryClassId ||
                          !allowedSecondary.contains(classId);
                    }
                    if (slot == 'primary' && currentClassId == classId) {
                      // Already primary
                    }

                    final color = isLocked
                        ? Colors.grey
                        : Color(classDef.colorHex);

                    return GestureDetector(
                      onTap: isLocked
                          ? null
                          : () {
                              Navigator.pop(context);
                              _switchClass(classId, slot);
                            },
                      child: Opacity(
                        opacity: isLocked ? 0.3 : 1.0,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : Colors.black26,
                            border: Border.all(
                              color: isSelected ? color : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                classDef.iconEmoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resolveClassName(
                                        classDef,
                                        ref.watch(localizationModeProvider),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: color,
                                        fontFamily: CandyFonts.display,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      resolveClassFocus(
                                        classDef,
                                        ref.watch(localizationModeProvider),
                                      ),
                                      style: const TextStyle(
                                        color: AppTheme.textDim,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      resolveClassDesc(
                                        classDef,
                                        ref.watch(localizationModeProvider),
                                      ),
                                      style: TextStyle(
                                        color: AppTheme.textDim.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 10,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isLocked)
                                const Icon(Icons.lock, color: Colors.grey)
                              else if (isSelected)
                                Icon(Icons.check_circle, color: color),
                            ],
                          ),
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
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppTheme.cyanNeon.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'confirm_switch'.tr(ref),
          style: const TextStyle(
            fontFamily: CandyFonts.display,
            color: AppTheme.cyanNeon,
            fontSize: 16,
          ),
        ),
        content: Text(
          'confirm_switch_desc'.tr(ref),
          style: const TextStyle(color: AppTheme.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(ref),
              style: const TextStyle(color: AppTheme.textDim),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'confirm'.tr(ref),
              style: const TextStyle(color: AppTheme.cyanNeon),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        await ref
            .read(classControllerProvider.notifier)
            .switchClass(newClassId: classId, slot: slot);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('class_switched'.tr(ref)),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('request_failed'.tr(ref)),
              backgroundColor: AppTheme.dangerOrange,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panelBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.dangerOrange.withValues(alpha: 0.5)),
        ),
        title: Text(
          'confirm_logout'.tr(ref),
          style: const TextStyle(
            fontFamily: CandyFonts.display,
            color: AppTheme.dangerOrange,
            fontSize: 16,
          ),
        ),
        content: Text(
          'confirm_logout_desc'.tr(ref),
          style: const TextStyle(color: AppTheme.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'cancel'.tr(ref),
              style: const TextStyle(color: AppTheme.textDim),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'logout'.tr(ref),
              style: const TextStyle(color: AppTheme.dangerOrange),
            ),
          ),
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
        title: Text(
          'system_character'.tr(ref),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: CandyFonts.display,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          _buildLanguageSelector(ref),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppTheme.cyanNeon),
              tooltip: 'edit_profile'.tr(ref),
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
          if (user == null) {
            return StatusPanel(message: 'no_data_recorded'.tr(ref));
          }
          final profile = profileState.value;

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 760
                        ? (constraints.maxWidth - 720) / 2
                        : 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(user),
                      const SizedBox(height: 28),

                      _buildSectionHeader('biometrics_board'.tr(ref)),
                      const SizedBox(height: 12),
                      _isEditing
                          ? _buildBiometricsEdit()
                          : _buildBiometricsReadonly(profile),
                      const SizedBox(height: 28),

                      _buildSectionHeader('battle_schedule'.tr(ref)),
                      const SizedBox(height: 12),
                      _isEditing
                          ? _buildScheduleEdit()
                          : _buildScheduleReadonly(profile),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildSectionHeader(
                              'active_classes'.tr(ref),
                            ),
                          ),
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
              ),
              if (classControllerState.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppTheme.cyanNeon),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.cyanNeon),
        ),
        error: (_, _) => StatusPanel(
          message: 'load_failed'.tr(ref),
          retryLabel: 'retry'.tr(ref),
          onRetry: () {
            ref.invalidate(currentUserProvider);
            ref.invalidate(currentUserProfileProvider);
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.cyanNeon,
            boxShadow: [BoxShadow(color: AppTheme.cyanNeon, blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(WidgetRef ref) => PopupMenuButton<AppLangMode>(
    icon: const Icon(Icons.language),
    tooltip: 'VI / EN',
    initialValue: ref.watch(localizationModeProvider),
    onSelected: (value) =>
        ref.read(localizationModeProvider.notifier).setMode(value),
    itemBuilder: (_) => const [
      PopupMenuItem(value: AppLangMode.vi, child: Text('VI')),
      PopupMenuItem(value: AppLangMode.en, child: Text('EN')),
    ],
  );

  Widget _buildHeaderSection(Map<String, dynamic> user) {
    final level = (user['level'] as num?)?.toInt() ?? 1;
    final title = (user['current_title'] as String?) ?? 'Seeker';
    final displayName = user['display_name'] ?? 'User';
    final email = (user['email'] as String?) ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground,
        border: Border(left: BorderSide(color: AppTheme.cyanNeon, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanNeon.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.purpleNeon, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purpleNeon.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Lv$level',
                style: const TextStyle(
                  fontFamily: CandyFonts.mono,
                  color: AppTheme.cyanNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing)
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.cyanNeon),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.only(bottom: 4),
                    ),
                  )
                else
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    color: AppTheme.textDim.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
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
        _buildHudBox('age'.tr(ref), age != null ? '$age' : '-'),
        const SizedBox(width: 10),
        _buildHudBox('height'.tr(ref), height != null ? '${height}cm' : '-'),
        const SizedBox(width: 10),
        _buildHudBox('weight'.tr(ref), weight != null ? '${weight}kg' : '-'),
      ],
    );
  }

  Widget _buildHudBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.panelBackground.withValues(alpha: 0.5),
          border: Border.all(color: AppTheme.cyanNeon.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cyanNeon.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: AppTheme.cyanNeon,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textDim,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricsEdit() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _editField(
                  'age'.tr(ref),
                  _ageController,
                  TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _editField(
                  '${'height'.tr(ref)} (cm)',
                  _heightController,
                  TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _editField(
                  '${'weight'.tr(ref)} (kg)',
                  _weightController,
                  const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return TextField(
      controller: controller,
      keyboardType: type,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppTheme.cyanNeon,
        fontFamily: CandyFonts.mono,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textDim, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.cyanNeon),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        isDense: true,
      ),
    );
  }

  String _dayLabel(String value) {
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    const vi = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final index = keys.indexOf(value);
    if (index < 0) return value;
    return ref.watch(localizationModeProvider) == AppLangMode.en
        ? en[index]
        : vi[index];
  }

  Widget _buildScheduleReadonly(Map<String, dynamic>? profile) {
    final gymDays = profile?['weekly_gym_days'] ?? 3;
    final homeDays = profile?['weekly_home_days'] ?? 0;
    final preferredDays =
        (profile?['preferred_training_days'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.purpleNeon.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'gym_home_ratio'.tr(ref),
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 12),
                ),
              ),
              Text(
                "$gymDays/$homeDays ${'days'.tr(ref)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: CandyFonts.mono,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'preferred_protocols'.tr(ref),
            style: const TextStyle(color: AppTheme.textDim, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: preferredDays
                .map(
                  (d) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cyanNeon.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.cyanNeon),
                    ),
                    child: Text(
                      _dayLabel(d),
                      style: const TextStyle(
                        color: AppTheme.cyanNeon,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleEdit() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.purpleNeon.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translateText(
              ref,
              vi: 'Buổi gym mỗi tuần: $_gymDays',
              en: 'Gym sessions per week: $_gymDays',
            ),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          Slider(
            value: _gymDays.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            activeColor: AppTheme.cyanNeon,
            inactiveColor: Colors.white12,
            onChanged: (val) => setState(() => _gymDays = val.toInt()),
          ),
          const SizedBox(height: 10),
          Text(
            translateText(
              ref,
              vi: 'Buổi tập tại nhà mỗi tuần: $_homeDays',
              en: 'Home sessions per week: $_homeDays',
            ),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          Slider(
            value: _homeDays.toDouble(),
            min: 0,
            max: 7,
            divisions: 7,
            activeColor: AppTheme.purpleNeon,
            inactiveColor: Colors.white12,
            onChanged: (val) => setState(() => _homeDays = val.toInt()),
          ),
          const SizedBox(height: 16),
          Text(
            'preferred_protocols'.tr(ref),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _weekDays.map((day) {
              final isSelected = _preferredDays.contains(day);
              return FilterChip(
                label: Text(
                  _dayLabel(day),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.cyanNeon,
                backgroundColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: isSelected ? AppTheme.cyanNeon : Colors.white24,
                  ),
                ),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _preferredDays.add(day);
                    } else {
                      _preferredDays.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesSection(
    AsyncValue<List<Map<String, dynamic>>> classesState,
  ) {
    return classesState.when(
      data: (classes) {
        final primary = classes.firstWhere(
          (c) => c['slot'] == 'primary',
          orElse: () => {},
        );
        final secondary = classes.firstWhere(
          (c) => c['slot'] == 'secondary',
          orElse: () => {},
        );

        final primaryId = primary['class_id'] as String?;

        return Column(
          children: [
            _buildClassHoloCard(primary, 'primary', null),
            const SizedBox(height: 12),
            _buildClassHoloCard(secondary, 'secondary', primaryId),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.cyanNeon),
      ),
      error: (_, _) => StatusPanel(
        message: 'load_failed'.tr(ref),
        retryLabel: 'retry'.tr(ref),
        onRetry: () => ref.invalidate(userClassesProvider),
      ),
    );
  }

  Widget _buildClassHoloCard(
    Map<String, dynamic> uc,
    String slot,
    String? primaryId,
  ) {
    final classId = uc['class_id'] as String?;
    if (classId == null) {
      return GestureDetector(
        onTap: () => _showClassPickerSheet(slot, '', primaryId),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              "+ ${'choose_class'.tr(ref)} ${slot.toUpperCase()}",
              style: const TextStyle(
                color: AppTheme.textDim,
                fontFamily: CandyFonts.display,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      );
    }

    final classDef = kClassDefinitions[classId];
    final level = (uc['level'] as num?)?.toInt() ?? 1;
    final isGraduated = (uc['is_graduated'] as bool?) ?? false;
    final color = classDef != null
        ? Color(classDef.colorHex)
        : AppTheme.cyanNeon;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showClassPickerSheet(slot, classId, primaryId),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(
                  classDef?.iconEmoji ?? '⚔️',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              classDef != null
                                  ? resolveClassName(
                                      classDef,
                                      ref.watch(localizationModeProvider),
                                    ).toUpperCase()
                                  : '',
                              style: TextStyle(
                                color: color,
                                fontFamily: CandyFonts.display,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isGraduated)
                            const Text('🎓', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${slot.toUpperCase()} · Lv $level',
                        style: const TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.swap_horiz,
                  color: AppTheme.textDim.withValues(alpha: 0.5),
                ),
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
              foregroundColor: AppTheme.textDim,
              side: const BorderSide(color: AppTheme.textDim),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'cancel'.tr(ref),
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyanNeon,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    'save'.tr(ref),
                    style: const TextStyle(
                      fontFamily: CandyFonts.display,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
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
        label: Text(
          'logout'.tr(ref),
          style: const TextStyle(
            fontFamily: CandyFonts.display,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.dangerOrange,
          side: BorderSide(color: AppTheme.dangerOrange.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
