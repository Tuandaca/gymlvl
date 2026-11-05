import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/candy/candy.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../routine_providers.dart';
import '../../routine_models.dart';

class PlannedWorkoutsScreen extends ConsumerWidget {
  const PlannedWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingPlannedWorkoutsProvider);
    final nextAsync = ref.watch(nextPlannedWorkoutProvider);

    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          translateText(ref, vi: 'Lịch tập dự kiến', en: 'Planned Workouts'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/routine/new'),
            tooltip: translateText(
              ref,
              vi: 'Tạo lịch trình',
              en: 'Create Routine',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNextWorkout(nextAsync, ref, context),
          const SizedBox(height: 16),
          Expanded(child: _buildUpcomingList(upcomingAsync, ref, context)),
        ],
      ),
    );
  }

  Widget _buildNextWorkout(
    AsyncValue<PlannedWorkout?> nextAsync,
    WidgetRef ref,
    BuildContext context,
  ) {
    return nextAsync.when(
      data: (next) => _buildNextWorkoutData(next, ref, context),
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CandySkeleton()),
      ),
      error: (error, stack) => CandyCard(
        margin: const EdgeInsets.all(16),
        child: CandyErrorState(
          message: translateText(
            ref,
            vi: 'Không thể tải bài tập tới',
            en: 'Failed to load next workout',
          ),
          onRetry: () => ref.invalidate(nextPlannedWorkoutProvider),
        ),
      ),
    );
  }

  Widget _buildNextWorkoutData(
    PlannedWorkout? next,
    WidgetRef ref,
    BuildContext context,
  ) {
    if (next == null) {
      return CandyCard(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              translateText(
                ref,
                vi: 'Không có bài tập tới',
                en: 'No upcoming workouts',
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              translateText(
                ref,
                vi: 'Hãy lên lịch bài tập tiếp theo',
                en: 'Schedule your next workout',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            CandyButton(
              label: translateText(
                ref,
                vi: 'Tạo lịch trình',
                en: 'Create Routine',
              ),
              icon: Icons.add,
              onPressed: () => context.push('/routine/new'),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final isToday =
        next.scheduledDate.year == now.year &&
        next.scheduledDate.month == now.month &&
        next.scheduledDate.day == now.day;
    final isTomorrow = next.scheduledDate.difference(now).inDays == 1;

    String whenText;
    if (isToday) {
      whenText = translateText(ref, vi: 'Hôm nay', en: 'Today');
    } else if (isTomorrow) {
      whenText = translateText(ref, vi: 'Ngày mai', en: 'Tomorrow');
    } else {
      whenText =
          '${next.scheduledDate.day}/${next.scheduledDate.month}/${next.scheduledDate.year}';
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: CandyCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  translateText(ref, vi: 'Bài tập tới', en: 'Next Workout'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              next.routineName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$whenText • ${translateText(ref, vi: 'Bắt đầu lúc', en: 'Starts at')} ${_formatTime(next.scheduledDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CandyButton(
                    variant: CandyButtonVariant.secondary,
                    label: translateText(
                      ref,
                      vi: 'Bắt đầu tập',
                      en: 'Start Workout',
                    ),
                    icon: Icons.play_arrow,
                    onPressed: () => _startWorkout(next.id, ref, context),
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CandyButton(
                    variant: CandyButtonVariant.secondary,
                    label: translateText(
                      ref,
                      vi: 'Lên lịch lại',
                      en: 'Reschedule',
                    ),
                    icon: Icons.schedule,
                    onPressed: () => _rescheduleWorkout(next.id, ref, context),
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingList(
    AsyncValue<List<PlannedWorkout>> upcomingAsync,
    WidgetRef ref,
    BuildContext context,
  ) {
    return upcomingAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return CandyEmptyState(
            icon: Icons.calendar_today,
            title: translateText(
              ref,
              vi: 'Chưa có bài tập dự kiến',
              en: 'No planned workouts',
            ),
            message: translateText(
              ref,
              vi: 'Lên lịch bài tập để xem ở đây',
              en: 'Schedule workouts to see them here',
            ),
            actionLabel: translateText(
              ref,
              vi: 'Tạo lịch trình',
              en: 'Create Routine',
            ),
            onAction: () => context.push('/routine/new'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: workouts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return _PlannedWorkoutCard(
              workout: workout,
              onStart: () => _startWorkout(workout.id, ref, context),
              onReschedule: () => _rescheduleWorkout(workout.id, ref, context),
              onCancel: () => _cancelWorkout(workout.id, ref, context),
            );
          },
        );
      },
      loading: () => const Center(child: CandySkeleton()),
      error: (error, stack) => CandyErrorState(
        message: translateText(
          ref,
          vi: 'Không thể tải bài tập dự kiến',
          en: 'Failed to load planned workouts',
        ),
        onRetry: () => ref.invalidate(upcomingPlannedWorkoutsProvider),
      ),
    );
  }

  Future<void> _startWorkout(
    String plannedWorkoutId,
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      await ref
          .read(routineRepositoryProvider)
          .startPlannedWorkout(plannedWorkoutId);
      if (context.mounted) {
        context.go('/workout/active');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start workout: $e')));
      }
    }
  }

  Future<void> _rescheduleWorkout(
    String plannedWorkoutId,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      locale: const Locale('vi'),
    );

    if (picked != null) {
      try {
        await ref
            .read(routineRepositoryProvider)
            .reschedule(scheduleId: plannedWorkoutId, newDate: picked);
        ref.invalidate(upcomingPlannedWorkoutsProvider);
        ref.invalidate(nextPlannedWorkoutProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                translateText(
                  ref,
                  vi: 'Đã lên lịch lại',
                  en: 'Workout rescheduled',
                ),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${translateText(ref, vi: 'Lên lịch lại thất bại', en: 'Failed to reschedule')}: $e',
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelWorkout(
    String plannedWorkoutId,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final confirmed = await CandyDialog.show<bool>(
      context: context,
      title: translateText(ref, vi: 'Hủy bài tập', en: 'Cancel Workout'),
      message: translateText(
        ref,
        vi: 'Bạn có chắc muốn hủy bài tập này?',
        en: 'Are you sure you want to cancel this workout?',
      ),
      primaryActionLabel: translateText(
        ref,
        vi: 'Hủy bài tập',
        en: 'Cancel Workout',
      ),
      primaryVariant: CandyButtonVariant.danger,
      onPrimaryAction: () => Navigator.pop(context, true),
      secondaryActionLabel: translateText(ref, vi: 'Giữ lại', en: 'Keep'),
      onSecondaryAction: () => Navigator.pop(context, false),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(routineRepositoryProvider)
            .cancelPlannedWorkout(plannedWorkoutId);
        ref.invalidate(upcomingPlannedWorkoutsProvider);
        ref.invalidate(nextPlannedWorkoutProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                translateText(
                  ref,
                  vi: 'Đã hủy bài tập',
                  en: 'Workout cancelled',
                ),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${translateText(ref, vi: 'Hủy thất bại', en: 'Failed to cancel')}: $e',
              ),
            ),
          );
        }
      }
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _PlannedWorkoutCard extends ConsumerWidget {
  final PlannedWorkout workout;
  final VoidCallback onStart;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const _PlannedWorkoutCard({
    required this.workout,
    required this.onStart,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isPast = workout.scheduledDate.isBefore(now);

    return CandyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${workout.scheduledDate.day}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      _getMonthShort(workout.scheduledDate.month),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workout.routineName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isPast)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              translateText(ref, vi: 'Đã lỡ', en: 'Missed'),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                            ),
                          )
                        else if (workout.status == PlannedWorkoutStatus.started)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              translateText(
                                ref,
                                vi: 'Đang tập',
                                en: 'In Progress',
                              ),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              translateText(
                                ref,
                                vi: 'Đã lên lịch',
                                en: 'Planned',
                              ),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    if (workout.routineSnapshot.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_countExercises(workout.routineSnapshot)} ${translateText(ref, vi: 'bài tập', en: 'exercises')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isPast &&
                  workout.status == PlannedWorkoutStatus.planned) ...[
                Expanded(
                  child: CandyButton(
                    variant: CandyButtonVariant.secondary,
                    label: translateText(ref, vi: 'Bắt đầu', en: 'Start'),
                    icon: Icons.play_arrow,
                    onPressed: onStart,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: CandyButton(
                  variant: CandyButtonVariant.secondary,
                  label: translateText(
                    ref,
                    vi: 'Lên lịch lại',
                    en: 'Reschedule',
                  ),
                  icon: Icons.schedule,
                  onPressed: onReschedule,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CandyButton(
                  variant: CandyButtonVariant.secondary,
                  label: translateText(ref, vi: 'Hủy', en: 'Cancel'),
                  icon: Icons.cancel,
                  onPressed: onCancel,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _countExercises(Map<String, dynamic> snapshot) {
    final routine = snapshot['routine'];
    if (routine == null) return 0;
    final exercises = routine['exercises'];
    if (exercises is List) return exercises.length;
    return 0;
  }

  String _getMonthShort(int month) {
    const months = [
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
    return months[month - 1];
  }
}
