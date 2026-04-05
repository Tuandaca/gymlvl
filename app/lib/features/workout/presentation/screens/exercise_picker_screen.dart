import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../../../ui/widgets/system_text_field.dart';
import '../../../../ui/widgets/system_panel.dart';
import '../../domain/exercise.dart';
import '../providers/exercise_providers.dart';
import '../widgets/exercise_card.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  final bool multiSelect;

  const ExercisePickerScreen({
    super.key,
    this.multiSelect = false,
  });

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Exercise> _selectedExercises = [];

  final List<String> _categories = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core'
  ];

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

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(filteredExercisesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.multiSelect ? 'CHỌN BÀI TẬP' : 'CHỌN BÀI TẬP'),
        actions: [
          if (widget.multiSelect && _selectedExercises.isNotEmpty)
            TextButton.icon(
              onPressed: _confirmSelection,
              icon: const Icon(Icons.check, size: 18),
              label: Text(
                'CHỌN (${_selectedExercises.length})',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.successGreen,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SystemPanel(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  SystemTextField(
                    controller: _searchController,
                    hintText: 'Tìm kiếm bài tập...',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).set(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip(null, 'Tất cả'),
                        ..._categories
                            .map((cat) => _buildCategoryChip(cat, cat)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Multi-select info banner
          if (widget.multiSelect)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.cyanNeon.withOpacity(0.08),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppTheme.cyanNeon.withOpacity(0.7), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Chọn nhiều bài tập, sau đó nhấn "CHỌN"',
                    style: TextStyle(
                      color: AppTheme.cyanNeon.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Exercise List
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64,
                            color: AppTheme.textDim.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy bài tập nào',
                          style: AppTheme.darkTheme.textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.textDim),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final selected = _isSelected(exercise);

                    if (widget.multiSelect) {
                      return Stack(
                        children: [
                          ExerciseCard(
                            exercise: exercise,
                            onTap: () => _toggleSelection(exercise),
                          ),
                          if (selected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.successGreen
                                          .withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                        ],
                      );
                    }

                    return ExerciseCard(
                      exercise: exercise,
                      onTap: () {
                        // Single select → return immediately
                        Navigator.of(context).pop(exercise);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.cyanNeon),
              ),
              error: (err, stack) => Center(
                child: Text('Lỗi: $err',
                    style: const TextStyle(color: AppTheme.dangerOrange)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = ref.read(selectedCategoryProvider) == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(selectedCategoryProvider.notifier).set(
              selected ? category : null);
        },
        selectedColor: AppTheme.cyanNeon.withOpacity(0.3),
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.cyanNeon : AppTheme.textDim,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? AppTheme.cyanNeon
                : AppTheme.cyanNeon.withOpacity(0.1),
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
