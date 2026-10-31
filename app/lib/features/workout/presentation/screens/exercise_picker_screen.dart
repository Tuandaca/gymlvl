import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ui/candy/candy_badge.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../../../ui/candy/candy_exercise_card.dart';
import '../../../../ui/candy/candy_text_field.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../workout_copy.dart';
import '../../domain/exercise.dart';
import '../providers/exercise_providers.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  final bool multiSelect;

  const ExercisePickerScreen({super.key, this.multiSelect = false});

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Exercise> _selectedExercises = [];
  bool _gridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(searchQueryProvider.notifier).set('');
      ref.read(selectedCategoryProvider.notifier).set(null);
      ref.read(selectedEquipmentProvider.notifier).set(null);
      ref.read(selectedMuscleProvider.notifier).set(null);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(Exercise exercise) {
    setState(() {
      final index = _selectedExercises.indexWhere((e) => e.id == exercise.id);
      if (index >= 0) {
        _selectedExercises.removeAt(index);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  bool _isSelected(Exercise exercise) {
    return _selectedExercises.any((e) => e.id == exercise.id);
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedExercises);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).clear();
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).clear();
    ref.read(selectedCategoryProvider.notifier).set(null);
    ref.read(selectedEquipmentProvider.notifier).set(null);
    ref.read(selectedMuscleProvider.notifier).set(null);
  }

  Widget _buildExerciseItem(Exercise exercise) {
    final selected = _isSelected(exercise);

    // Multi-select shows an explicit check badge instead of the default
    // navigation arrow so tapping toggles selection rather than navigating.
    Widget? trailing;
    if (widget.multiSelect) {
      trailing = selected
          ? Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: CandyColors.hotPink,
                shape: BoxShape.circle,
                border: CandyColors.standardBorder(width: 1.5),
              ),
              child: const Icon(Icons.check, color: CandyColors.card, size: 16),
            )
          : const SizedBox.shrink();
    }

    return Semantics(
      button: true,
      label: exercise.name,
      child: CandyExerciseCard(
        key: ValueKey(exercise.id),
        title: exercise.name,
        category: exercise.category,
        equipment: exercise.equipment,
        isSelected: selected,
        onTap: () {
          if (widget.multiSelect) {
            _toggleSelection(exercise);
          } else {
            // Single select → return immediately
            Navigator.of(context).pop(exercise);
          }
        },
        trailing: trailing,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CandyEmptyState(
          icon: Icons.search_off,
          title: workoutText(ref, 'empty_state_title'),
          message: workoutText(ref, 'empty_state_message'),
          actionLabel: _hasActiveFilters ? workoutText(ref, 'clear_all') : null,
          onAction: _hasActiveFilters ? _clearAllFilters : null,
          actionVariant: CandyButtonVariant.secondary,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CandyErrorState(
          title: workoutText(ref, 'error_state_title'),
          message: workoutText(ref, 'error_state_message'),
          retryLabel: workoutText(ref, 'retry'),
          onRetry: () => ref.invalidate(exerciseListProvider),
        ),
      ),
    );
  }

  bool get _hasActiveFilters {
    final searchQuery = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final equipment = ref.watch(selectedEquipmentProvider);
    final muscle = ref.watch(selectedMuscleProvider);
    return searchQuery.isNotEmpty ||
        category != null ||
        equipment != null ||
        muscle != null;
  }

  Widget _activeFilterChip(String label, String value, VoidCallback onRemove) {
    return Semantics(
      button: true,
      label: '$label: $value, bấm để xóa',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: CandyBadge(
          label: '$label: $value',
          variant: CandyBadgeVariant.pink,
          onTap: onRemove,
          fontSize: 11,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required AsyncValue<List<String>> async,
    required String labelKey,
    required String? selected,
    required void Function(String?) onChanged,
  }) {
    return async.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2.0, bottom: 8.0),
              child: Text(
                workoutText(ref, labelKey),
                style: const TextStyle(
                  fontFamily: CandyFonts.display,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CandyColors.ink,
                  letterSpacing: 0.3,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = selected == item;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Semantics(
                      button: true,
                      label:
                          '$labelKey: $item, ${isSelected ? 'đã chọn' : 'chọn để lọc'}',
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 48,
                          minWidth: 48,
                        ),
                        child: CandyBadge(
                          label: item,
                          variant: isSelected
                              ? CandyBadgeVariant.pink
                              : CandyBadgeVariant.card,
                          onTap: () => onChanged(isSelected ? null : item),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (Object error, StackTrace stack) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(filteredExercisesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final equipment = ref.watch(selectedEquipmentProvider);
    final muscle = ref.watch(selectedMuscleProvider);
    final categoriesAsync = ref.watch(exerciseCategoriesProvider);
    final equipmentsAsync = ref.watch(exerciseEquipmentsProvider);
    final musclesAsync = ref.watch(exerciseMusclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(workoutText(ref, 'select_exercises')),
        actions: [
          if (widget.multiSelect && _selectedExercises.isNotEmpty)
            TextButton.icon(
              onPressed: _confirmSelection,
              icon: const Icon(Icons.check, size: 18),
              label: Text(
                '${workoutText(ref, 'finish')} (${_selectedExercises.length})',
                style: const TextStyle(
                  fontFamily: CandyFonts.mono,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: CandyColors.hotPink),
            ),
          IconButton(
            icon: Icon(_gridView ? Icons.list_rounded : Icons.grid_view),
            onPressed: () => setState(() => _gridView = !_gridView),
            tooltip: workoutText(ref, _gridView ? 'view_list' : 'view_grid'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CandyCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CandyTextField(
                    controller: _searchController,
                    hintText: workoutText(ref, 'search'),
                    prefixIcon: Icons.search,
                    suffix: searchQuery.isNotEmpty
                        ? Semantics(
                            button: true,
                            label: workoutText(ref, 'clear_search'),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: _clearSearch,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          )
                        : null,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).set(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Active filter badges
                  if (_hasActiveFilters) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (searchQuery.isNotEmpty)
                          _activeFilterChip(
                            workoutText(ref, 'search'),
                            searchQuery,
                            _clearSearch,
                          ),
                        if (category != null)
                          _activeFilterChip(
                            workoutText(ref, 'category'),
                            category,
                            () => ref
                                .read(selectedCategoryProvider.notifier)
                                .set(null),
                          ),
                        if (equipment != null)
                          _activeFilterChip(
                            workoutText(ref, 'equipment'),
                            equipment,
                            () => ref
                                .read(selectedEquipmentProvider.notifier)
                                .set(null),
                          ),
                        if (muscle != null)
                          _activeFilterChip(
                            workoutText(ref, 'muscle_group'),
                            muscle,
                            () => ref
                                .read(selectedMuscleProvider.notifier)
                                .set(null),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CandyButton(
                        label: workoutText(ref, 'clear_all'),
                        variant: CandyButtonVariant.neutral,
                        size: CandyButtonSize.small,
                        isFullWidth: false,
                        onPressed: _clearAllFilters,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Dynamic filter chips derived from actual exercise data
                  _buildFilterSection(
                    async: categoriesAsync,
                    labelKey: 'category',
                    selected: category,
                    onChanged: (value) =>
                        ref.read(selectedCategoryProvider.notifier).set(value),
                  ),
                  _buildFilterSection(
                    async: equipmentsAsync,
                    labelKey: 'equipment',
                    selected: equipment,
                    onChanged: (value) =>
                        ref.read(selectedEquipmentProvider.notifier).set(value),
                  ),
                  _buildFilterSection(
                    async: musclesAsync,
                    labelKey: 'muscle_group',
                    selected: muscle,
                    onChanged: (value) =>
                        ref.read(selectedMuscleProvider.notifier).set(value),
                  ),
                ],
              ),
            ),
          ),

          // Multi-select info banner
          if (widget.multiSelect)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: CandyColors.hotPink.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: CandyColors.hotPink.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workoutText(ref, 'select_exercises'),
                      style: const TextStyle(
                        color: CandyColors.ink,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Exercise List / Grid
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return _buildEmptyState();
                }

                if (_gridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12.0,
                          crossAxisSpacing: 12.0,
                          childAspectRatio: 1.6,
                        ),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseItem(exercises[index]);
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildExerciseItem(exercises[index]),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: CandyColors.hotPink),
              ),
              error: (err, stack) => _buildErrorState(),
            ),
          ),
        ],
      ),
    );
  }
}
