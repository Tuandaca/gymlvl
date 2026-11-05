import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/candy/candy.dart';
import '../../../../core/localization/localization_engine.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import '../../routine_providers.dart';
import '../../routine_models.dart';

class RoutineEditorScreen extends ConsumerStatefulWidget {
  final String? routineId;

  const RoutineEditorScreen({super.key, this.routineId});

  @override
  ConsumerState<RoutineEditorScreen> createState() =>
      _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  final _nameController = TextEditingController();
  String _emoji = '💪';
  final List<_ExerciseSlot> _exercises = [];
  bool _isLoading = false;
  bool _isNew = true;

  @override
  void initState() {
    super.initState();
    if (widget.routineId != null) {
      _isNew = false;
      _loadRoutine();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutine() async {
    setState(() => _isLoading = true);
    try {
      final routine = await ref
          .read(routineRepositoryProvider)
          .getRoutine(widget.routineId!);
      if (routine != null) {
        _nameController.text = routine.name;
        _emoji = routine.emoji ?? '💪';
        _exercises.clear();
        for (final ex in routine.exercises) {
          _exercises.add(_ExerciseSlot.fromRoutineExercise(ex));
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = !_isNew;

    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? translateText(
                  ref,
                  vi: 'Chỉnh sửa lịch trình',
                  en: 'Edit Routine',
                )
              : translateText(
                  ref,
                  vi: 'Tạo lịch trình mới',
                  en: 'Create Routine',
                ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing) ...[
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _duplicateRoutine,
              tooltip: translateText(ref, vi: 'Nhân bản', en: 'Duplicate'),
            ),
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: _archiveRoutine,
              tooltip: translateText(ref, vi: 'Lưu trữ', en: 'Archive'),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CandySkeleton())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildExerciseList(),
                        const SizedBox(height: 24),
                        _buildAddExerciseButton(),
                      ],
                    ),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: CandyTextField(
                controller: _nameController,
                labelText: translateText(
                  ref,
                  vi: 'Tên lịch trình',
                  en: 'Routine Name',
                ),
                hintText: translateText(
                  ref,
                  vi: 'Nhập tên lịch trình',
                  en: 'Enter routine name',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.emoji_emotions),
              onPressed: _pickEmoji,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseList() {
    if (_exercises.isEmpty) {
      return CandyEmptyState(
        icon: Icons.fitness_center,
        title: translateText(
          ref,
          vi: 'Chưa có bài tập',
          en: 'No exercises yet',
        ),
        message: translateText(
          ref,
          vi: 'Thêm bài tập vào lịch trình',
          en: 'Add exercises to routine',
        ),
        actionLabel: translateText(ref, vi: 'Thêm bài tập', en: 'Add Exercise'),
        onAction: _addExercise,
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _exercises.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _exercises.removeAt(oldIndex);
          _exercises.insert(newIndex, item);
          for (var i = 0; i < _exercises.length; i++) {
            _exercises[i] = _exercises[i].copyWith(orderIndex: i);
          }
        });
      },
      itemBuilder: (context, index) {
        final slot = _exercises[index];
        return _ExerciseSlotCard(
          key: ValueKey(slot.id),
          slot: slot,
          index: index,
          onEdit: () => _editExercise(index),
          onRemove: () => _removeExercise(index),
          onReplace: () => _replaceExercise(index),
        );
      },
    );
  }

  Widget _buildAddExerciseButton() {
    return CandyButton(
      variant: CandyButtonVariant.secondary,
      icon: Icons.add,
      label: translateText(ref, vi: 'Thêm bài tập', en: 'Add Exercise'),
      onPressed: _addExercise,
      isFullWidth: true,
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CandyButton(
        label: _isNew
            ? translateText(ref, vi: 'Tạo lịch trình', en: 'Create Routine')
            : translateText(ref, vi: 'Lưu thay đổi', en: 'Save Changes'),
        icon: Icons.save,
        onPressed: _saveRoutine,
        isFullWidth: true,
      ),
    );
  }

  Future<void> _pickEmoji() async {
    final emojis = [
      '💪',
      '🏋️',
      '🏃',
      '🧘',
      '🤸',
      '🏊',
      '🚴',
      '⚽',
      '🏀',
      '🎾',
      '🥊',
      '🤼',
    ];
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(translateText(ref, vi: 'Chọn emoji', en: 'Select emoji')),
        children: emojis
            .map(
              (e) => SimpleDialogOption(
                child: Text(e, style: const TextStyle(fontSize: 28)),
                onPressed: () => Navigator.pop(context, e),
              ),
            )
            .toList(),
      ),
    );
    if (picked != null) {
      setState(() => _emoji = picked);
    }
  }

  Future<void> _addExercise() async {
    final result = await context.push<Map<String, dynamic>>(
      '/exercise-picker?multiSelect=false',
    );
    if (result != null && result['exercise'] != null) {
      final exercise = result['exercise'];
      setState(() {
        _exercises.add(
          _ExerciseSlot(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            exerciseId: exercise.id,
            exerciseName: exercise.nameVi ?? exercise.nameEn,
            orderIndex: _exercises.length,
            sets: 3,
            reps: 10,
            weightKg: 0,
            mode: 'reps-weight',
          ),
        );
      });
    }
  }

  Future<void> _editExercise(int index) async {
    final slot = _exercises[index];

    final setsController = TextEditingController(text: slot.sets.toString());
    final repsController = TextEditingController(text: slot.reps.toString());
    final weightController = TextEditingController(
      text: slot.weightKg.toString(),
    );
    final restController = TextEditingController(
      text: (slot.restSeconds ?? 90).toString(),
    );

    final result = await CandyDialog.show<Map<String, dynamic>>(
      context: context,
      title: translateText(
        ref,
        vi: 'Cấu hình bài tập',
        en: 'Edit Exercise Config',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              slot.exerciseName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            CandyTextField(
              controller: setsController,
              labelText: translateText(ref, vi: 'Số set', en: 'Sets'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CandyTextField(
              controller: repsController,
              labelText: translateText(ref, vi: 'Số lần', en: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CandyTextField(
              controller: weightController,
              labelText: translateText(
                ref,
                vi: 'Trọng lượng (kg)',
                en: 'Weight (kg)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CandyTextField(
              controller: restController,
              labelText: translateText(
                ref,
                vi: 'Nghỉ (giây)',
                en: 'Rest (seconds)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      primaryActionLabel: translateText(ref, vi: 'Lưu', en: 'Save'),
      onPrimaryAction: () => Navigator.pop(context, {
        'sets': int.tryParse(setsController.text) ?? 3,
        'reps': int.tryParse(repsController.text) ?? 10,
        'weightKg': double.tryParse(weightController.text) ?? 0,
        'restSeconds': int.tryParse(restController.text) ?? 90,
      }),
      secondaryActionLabel: translateText(ref, vi: 'Hủy', en: 'Cancel'),
      onSecondaryAction: () => Navigator.pop(context),
    );

    if (result != null) {
      setState(() {
        _exercises[index] = slot.copyWith(
          sets: result['sets'] as int,
          reps: result['reps'] as int,
          weightKg: result['weightKg'] as double,
          restSeconds: result['restSeconds'] as int,
        );
      });
    }
  }

  Future<void> _removeExercise(int index) async {
    final confirmed = await CandyDialog.show<bool>(
      context: context,
      title: translateText(ref, vi: 'Xóa bài tập', en: 'Remove Exercise'),
      message: translateText(
        ref,
        vi: 'Bạn có chắc muốn xóa bài tập này?',
        en: 'Are you sure you want to remove this exercise?',
      ),
      primaryActionLabel: translateText(ref, vi: 'Xóa', en: 'Remove'),
      primaryVariant: CandyButtonVariant.danger,
      onPrimaryAction: () => Navigator.pop(context, true),
      secondaryActionLabel: translateText(ref, vi: 'Hủy', en: 'Cancel'),
      onSecondaryAction: () => Navigator.pop(context, false),
    );

    if (confirmed == true) {
      setState(() {
        _exercises.removeAt(index);
        for (var i = 0; i < _exercises.length; i++) {
          _exercises[i] = _exercises[i].copyWith(orderIndex: i);
        }
      });
    }
  }

  Future<void> _replaceExercise(int index) async {
    final result = await context.push<Map<String, dynamic>>(
      '/exercise-picker?multiSelect=false',
    );
    if (result != null && result['exercise'] != null) {
      final exercise = result['exercise'];
      setState(() {
        _exercises[index] = _exercises[index].copyWith(
          exerciseId: exercise.id,
          exerciseName: exercise.nameVi ?? exercise.nameEn,
        );
      });
    }
  }

  Future<void> _saveRoutine() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translateText(
              ref,
              vi: 'Tên lịch trình là bắt buộc',
              en: 'Routine name is required',
            ),
          ),
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translateText(
              ref,
              vi: 'Cần ít nhất một bài tập',
              en: 'At least one exercise required',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(routineRepositoryProvider);

      if (_isNew) {
        final routine = Routine(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          userId: '',
          name: name,
          emoji: _emoji,
          exercises: _exercises
              .map(
                (e) => RoutineExercise(
                  id: e.id,
                  routineId: '',
                  exerciseId: e.exerciseId,
                  orderIndex: e.orderIndex,
                  sets: e.sets,
                  reps: e.reps,
                  weightKg: e.weightKg,
                  restSeconds: e.restSeconds,
                  mode: WorkoutMode.values.firstWhere(
                    (m) => m.wireValue == e.mode,
                    orElse: () => WorkoutMode.repsWeight,
                  ),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              )
              .toList(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repo.createRoutine(routine);
      } else {
        final routine = await repo.getRoutine(widget.routineId!);
        if (routine != null) {
          final updated = routine.copyWith(
            name: name,
            emoji: _emoji,
            exercises: _exercises
                .map(
                  (e) => RoutineExercise(
                    id: e.id,
                    routineId: widget.routineId!,
                    exerciseId: e.exerciseId,
                    orderIndex: e.orderIndex,
                    sets: e.sets,
                    reps: e.reps,
                    weightKg: e.weightKg,
                    restSeconds: e.restSeconds,
                    mode: WorkoutMode.values.firstWhere(
                      (m) => m.wireValue == e.mode,
                      orElse: () => WorkoutMode.repsWeight,
                    ),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                )
                .toList(),
            updatedAt: DateTime.now(),
          );
          await repo.updateRoutine(updated);
        }
      }

      ref.invalidate(routinesProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isNew
                  ? translateText(
                      ref,
                      vi: 'Đã tạo lịch trình',
                      en: 'Routine created',
                    )
                  : translateText(
                      ref,
                      vi: 'Đã lưu lịch trình',
                      en: 'Routine saved',
                    ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${translateText(ref, vi: 'Lưu thất bại', en: 'Failed to save')}: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _duplicateRoutine() async {
    final nameController = TextEditingController(
      text: '${_nameController.text} (Copy)',
    );

    final newName = await CandyDialog.show<String>(
      context: context,
      title: translateText(
        ref,
        vi: 'Nhân bản lịch trình',
        en: 'Duplicate Routine',
      ),
      content: CandyTextField(
        controller: nameController,
        labelText: translateText(ref, vi: 'Tên lịch trình', en: 'Routine Name'),
        autofocus: true,
      ),
      primaryActionLabel: translateText(ref, vi: 'Nhân bản', en: 'Duplicate'),
      onPrimaryAction: () => Navigator.pop(context, nameController.text.trim()),
      secondaryActionLabel: translateText(ref, vi: 'Hủy', en: 'Cancel'),
      onSecondaryAction: () => Navigator.pop(context),
    );

    if (newName != null && newName.isNotEmpty) {
      try {
        await ref
            .read(routineRepositoryProvider)
            .duplicateRoutine(routineId: widget.routineId!, newName: newName);
        ref.invalidate(routinesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                translateText(
                  ref,
                  vi: 'Đã nhân bản lịch trình',
                  en: 'Routine duplicated',
                ),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${translateText(ref, vi: 'Nhân bản thất bại', en: 'Failed to duplicate')}: $e',
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _archiveRoutine() async {
    final confirmed = await CandyDialog.show<bool>(
      context: context,
      title: translateText(
        ref,
        vi: 'Lưu trữ lịch trình',
        en: 'Archive Routine',
      ),
      message: translateText(
        ref,
        vi: 'Bạn có chắc muốn lưu trữ lịch trình này?',
        en: 'Are you sure you want to archive this routine?',
      ),
      primaryActionLabel: translateText(ref, vi: 'Lưu trữ', en: 'Archive'),
      primaryVariant: CandyButtonVariant.danger,
      onPrimaryAction: () => Navigator.pop(context, true),
      secondaryActionLabel: translateText(ref, vi: 'Hủy', en: 'Cancel'),
      onSecondaryAction: () => Navigator.pop(context, false),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(routineRepositoryProvider)
            .archiveRoutine(widget.routineId!);
        ref.invalidate(routinesProvider);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                translateText(
                  ref,
                  vi: 'Đã lưu trữ lịch trình',
                  en: 'Routine archived',
                ),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${translateText(ref, vi: 'Lưu trữ thất bại', en: 'Failed to archive')}: $e',
              ),
            ),
          );
        }
      }
    }
  }
}

class _ExerciseSlot {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final int orderIndex;
  final int sets;
  final int reps;
  final double weightKg;
  final int? restSeconds;
  final String mode;

  const _ExerciseSlot({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.orderIndex,
    required this.sets,
    required this.reps,
    required this.weightKg,
    this.restSeconds,
    required this.mode,
  });

  factory _ExerciseSlot.fromRoutineExercise(RoutineExercise ex) =>
      _ExerciseSlot(
        id: ex.id,
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseId,
        orderIndex: ex.orderIndex,
        sets: ex.sets,
        reps: ex.reps,
        weightKg: ex.weightKg,
        restSeconds: ex.restSeconds,
        mode: ex.mode.wireValue,
      );

  _ExerciseSlot copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    int? orderIndex,
    int? sets,
    int? reps,
    double? weightKg,
    int? restSeconds,
    String? mode,
  }) => _ExerciseSlot(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    exerciseName: exerciseName ?? this.exerciseName,
    orderIndex: orderIndex ?? this.orderIndex,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    weightKg: weightKg ?? this.weightKg,
    restSeconds: restSeconds ?? this.restSeconds,
    mode: mode ?? this.mode,
  );
}

class _ExerciseSlotCard extends ConsumerWidget {
  final _ExerciseSlot slot;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  const _ExerciseSlotCard({
    super.key,
    required this.slot,
    required this.index,
    required this.onEdit,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyCard(
      key: key,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        slot.exerciseName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${slot.sets}x${slot.reps} • ${slot.weightKg.toStringAsFixed(1)}kg • ${slot.restSeconds ?? 90}s ${translateText(ref, vi: 'nghỉ', en: 'rest')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                  break;
                case 'replace':
                  onReplace();
                  break;
                case 'remove':
                  onRemove();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 8),
                    Text(translateText(ref, vi: 'Sửa', en: 'Edit')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'replace',
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz, size: 20),
                    const SizedBox(width: 8),
                    Text(translateText(ref, vi: 'Thay thế', en: 'Replace')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      translateText(ref, vi: 'Xóa', en: 'Remove'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
