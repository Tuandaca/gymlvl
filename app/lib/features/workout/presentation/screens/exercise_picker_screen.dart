import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../ui/widgets/system_text_field.dart';
import '../../../ui/widgets/system_panel.dart';
import '../providers/exercise_providers.dart';
import '../widgets/exercise_card.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(filteredExercisesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHỌN BÀI TẬP'),
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
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip(null, 'Tất cả'),
                        ..._categories.map((cat) => _buildCategoryChip(cat, cat)),
                      ],
                    ),
                  ),
                ],
              ),
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
                        Icon(Icons.search_off, size: 64, color: AppTheme.textDim.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy bài tập nào',
                          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.textDim),
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
                    return ExerciseCard(
                      exercise: exercise,
                      onTap: () {
                        // Return selected exercise
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
                child: Text('Lỗi: $err', style: const TextStyle(color: AppTheme.dangerOrange)),
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
          ref.read(selectedCategoryProvider.notifier).state = selected ? category : null;
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
            color: isSelected ? AppTheme.cyanNeon : AppTheme.cyanNeon.withOpacity(0.1),
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
