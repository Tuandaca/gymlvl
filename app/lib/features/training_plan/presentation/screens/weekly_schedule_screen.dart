import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/candy/candy.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../routine_providers.dart';
import '../../routine_models.dart';

class WeeklyScheduleScreen extends ConsumerStatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  ConsumerState<WeeklyScheduleScreen> createState() =>
      _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends ConsumerState<WeeklyScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routinesProvider);

    return CandyScaffold(
      appBar: AppBar(
        title: Text(translateText(ref, vi: 'Lịch tuần', en: 'Weekly Schedule')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addRoutineToSchedule,
            tooltip: translateText(
              ref,
              vi: 'Thêm vào lịch',
              en: 'Add to Schedule',
            ),
          ),
        ],
      ),
      body: routinesAsync.when(
        data: (routines) {
          if (routines.isEmpty) {
            return CandyEmptyState(
              icon: Icons.calendar_today,
              title: translateText(
                ref,
                vi: 'Chưa có lịch trình',
                en: 'No routines for schedule',
              ),
              message: translateText(
                ref,
                vi: 'Hãy tạo lịch trình trước',
                en: 'Create routines first',
              ),
              actionLabel: translateText(
                ref,
                vi: 'Tạo lịch trình',
                en: 'Create Routine',
              ),
              onAction: () => context.push('/routine/new'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWeekHeader(),
              const SizedBox(height: 16),
              ..._buildWeekDays(routines),
            ],
          );
        },
        loading: () => const Center(child: CandySkeleton()),
        error: (error, stack) => CandyErrorState(
          message: translateText(
            ref,
            vi: 'Không thể tải lịch trình',
            en: 'Failed to load routines',
          ),
          onRetry: () => ref.invalidate(routinesProvider),
        ),
      ),
    );
  }

  Widget _buildWeekHeader() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${translateText(ref, vi: 'Tuần', en: 'Week')} ${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          icon: const Icon(Icons.today),
          label: Text(translateText(ref, vi: 'Tuần này', en: 'This Week')),
          onPressed: () {
            // Could add scroll to today logic here
          },
        ),
      ],
    );
  }

  List<Widget> _buildWeekDays(List<Routine> routines) {
    final weekDays = [
      (1, translateText(ref, vi: 'T2', en: 'Mon')),
      (2, translateText(ref, vi: 'T3', en: 'Tue')),
      (3, translateText(ref, vi: 'T4', en: 'Wed')),
      (4, translateText(ref, vi: 'T5', en: 'Thu')),
      (5, translateText(ref, vi: 'T6', en: 'Fri')),
      (6, translateText(ref, vi: 'T7', en: 'Sat')),
      (7, translateText(ref, vi: 'CN', en: 'Sun')),
    ];

    return weekDays.map((day) {
      final weekday = day.$1;
      final dayName = day.$2;
      final isToday = DateTime.now().weekday == weekday;
      final scheduledRoutines = _getRoutinesForWeekday(routines, weekday);

      return _WeekDayCard(
        weekday: weekday,
        dayName: dayName,
        isToday: isToday,
        routines: scheduledRoutines,
        onAddRoutine: () => _assignRoutineToWeekday(weekday),
        onStartWorkout: (routineId) => _startWorkoutFromRoutine(routineId),
      );
    }).toList();
  }

  List<Routine> _getRoutinesForWeekday(List<Routine> routines, int weekday) {
    // For now, return empty - in real implementation this would query schedules
    // This is a simplified version
    return [];
  }

  Future<void> _addRoutineToSchedule() async {
    final routines = await ref.read(routinesProvider.future);
    if (!mounted || routines.isEmpty) return;

    final routineNames = routines.map((r) => r.name).toList();

    final selectedRoutine = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          translateText(ref, vi: 'Chọn lịch trình', en: 'Select Routine'),
        ),
        children: routineNames
            .map(
              (name) => SimpleDialogOption(
                child: Text(name),
                onPressed: () => Navigator.pop(context, name),
              ),
            )
            .toList(),
      ),
    );

    if (selectedRoutine != null) {
      final weekday = await _selectWeekday();
      if (weekday != null) {
        final routine = routines.firstWhere((r) => r.name == selectedRoutine);
        try {
          await ref
              .read(routineRepositoryProvider)
              .scheduleRoutine(
                routineId: routine.id,
                config: ScheduleRoutineConfig.fixedWeek(
                  routineId: routine.id,
                  weekday: weekday,
                ),
              );
          ref.invalidate(routineSchedulesProvider(routine.id));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  translateText(
                    ref,
                    vi: 'Đã lên lịch',
                    en: 'Routine scheduled',
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
                  '${translateText(ref, vi: 'Lên lịch thất bại', en: 'Failed to schedule')}: $e',
                ),
              ),
            );
          }
        }
      }
    }
  }

  Future<int?> _selectWeekday() async {
    final weekDays = [
      (1, translateText(ref, vi: 'Thứ 2', en: 'Monday')),
      (2, translateText(ref, vi: 'Thứ 3', en: 'Tuesday')),
      (3, translateText(ref, vi: 'Thứ 4', en: 'Wednesday')),
      (4, translateText(ref, vi: 'Thứ 5', en: 'Thursday')),
      (5, translateText(ref, vi: 'Thứ 6', en: 'Friday')),
      (6, translateText(ref, vi: 'Thứ 7', en: 'Saturday')),
      (7, translateText(ref, vi: 'Chủ nhật', en: 'Sunday')),
    ];

    return await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(translateText(ref, vi: 'Chọn thứ', en: 'Select Weekday')),
        children: weekDays
            .map(
              (day) => SimpleDialogOption(
                child: Text(day.$2),
                onPressed: () => Navigator.pop(context, day.$1),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _assignRoutineToWeekday(int weekday) async {
    await _addRoutineToSchedule();
  }

  Future<void> _startWorkoutFromRoutine(String routineId) async {
    try {
      final now = DateTime.now();
      final planned = await ref
          .read(routineRepositoryProvider)
          .createPlannedWorkout(
            routineId: routineId,
            scheduledDate: DateTime(now.year, now.month, now.day),
          );

      await ref.read(routineRepositoryProvider).startPlannedWorkout(planned.id);

      if (mounted) {
        context.go('/workout/active');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start workout: $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class _WeekDayCard extends ConsumerWidget {
  final int weekday;
  final String dayName;
  final bool isToday;
  final List<Routine> routines;
  final VoidCallback onAddRoutine;
  final void Function(String routineId) onStartWorkout;

  const _WeekDayCard({
    required this.weekday,
    required this.dayName,
    required this.isToday,
    required this.routines,
    required this.onAddRoutine,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  dayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isToday
                      ? translateText(ref, vi: 'Hôm nay', en: 'Today')
                      : _getFullDayName(weekday),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (routines.isEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(translateText(ref, vi: 'Thêm', en: 'Add')),
                  onPressed: onAddRoutine,
                ),
            ],
          ),
          if (routines.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...routines.map(
              (routine) => _RoutineInDayCard(
                routine: routine,
                onStart: () => onStartWorkout(routine.id),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    translateText(ref, vi: 'Ngày nghỉ', en: 'Rest Day'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(
                      translateText(
                        ref,
                        vi: 'Lên lịch tập',
                        en: 'Schedule Workout',
                      ),
                    ),
                    onPressed: onAddRoutine,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getFullDayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }
}

class _RoutineInDayCard extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onStart;

  const _RoutineInDayCard({required this.routine, required this.onStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (routine.emoji != null) ...[
            Text(routine.emoji!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              routine.name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          CandyButton(
            variant: CandyButtonVariant.secondary,
            label: translateText(ref, vi: 'Bắt đầu', en: 'Start'),
            icon: Icons.play_arrow,
            onPressed: onStart,
            size: CandyButtonSize.small,
          ),
        ],
      ),
    );
  }
}
