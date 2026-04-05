import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/theme/app_theme.dart';
import '../controllers/workout_history_controller.dart';
import '../widgets/workout_summary_card.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('LỊCH SỬ TẬP LUYỆN'),
      ),
      body: historyAsync.when(
        data: (workouts) {
          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded,
                      size: 80, color: AppTheme.textDim.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có buổi tập nào!',
                    style: TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 18,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hoàn thành buổi tập đầu tiên để tạo lịch sử',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.cyanNeon,
            backgroundColor: AppTheme.panelBackground,
            onRefresh: () async {
              ref.invalidate(workoutHistoryProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return WorkoutSummaryCard(
                  workout: workout,
                  onTap: () {
                    context.push('/workout/detail/${workout.id}');
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.cyanNeon),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.dangerOrange, size: 48),
              const SizedBox(height: 16),
              Text('Lỗi: $err',
                  style: const TextStyle(color: AppTheme.dangerOrange)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(workoutHistoryProvider),
                child: const Text('Thử lại',
                    style: TextStyle(color: AppTheme.cyanNeon)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
