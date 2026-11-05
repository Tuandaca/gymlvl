import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/candy/candy.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../routine_providers.dart';
import '../../routine_models.dart';

class RoutineListScreen extends ConsumerStatefulWidget {
  const RoutineListScreen({super.key});

  @override
  ConsumerState<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends ConsumerState<RoutineListScreen> {
  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routinesProvider);

    return CandyScaffold(
      appBar: AppBar(
        title: Text(translateText(ref, vi: 'Lịch trình', en: 'Routines')),
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
      body: routinesAsync.when(
        data: (routines) {
          if (routines.isEmpty) {
            return CandyEmptyState(
              icon: Icons.fitness_center,
              title: translateText(
                ref,
                vi: 'Chưa có lịch trình',
                en: 'No routines yet',
              ),
              message: translateText(
                ref,
                vi: 'Hãy tạo lịch trình đầu tiên của bạn',
                en: 'Create your first routine',
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
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _RoutineCard(
                routine: routine,
                onTap: () => context.push('/routine/${routine.id}'),
                onDuplicate: () => _duplicateRoutine(routine),
                onArchive: () => _archiveRoutine(routine.id),
              );
            },
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

  Future<void> _duplicateRoutine(Routine routine) async {
    final nameController = TextEditingController(
      text: '${routine.name} (Copy)',
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
            .duplicateRoutine(routineId: routine.id, newName: newName);
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

  Future<void> _archiveRoutine(String routineId) async {
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
        await ref.read(routineRepositoryProvider).archiveRoutine(routineId);
        ref.invalidate(routinesProvider);
        if (mounted) {
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

class _RoutineCard extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onArchive;

  const _RoutineCard({
    required this.routine,
    required this.onTap,
    required this.onDuplicate,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyCard(
      onTap: onTap,
      child: Row(
        children: [
          if (routine.emoji != null) ...[
            Text(routine.emoji!, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${routine.exerciseCount} ${translateText(ref, vi: 'bài tập', en: 'exercises')}',
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
                case 'duplicate':
                  onDuplicate();
                  break;
                case 'archive':
                  onArchive();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    const Icon(Icons.copy, size: 20),
                    const SizedBox(width: 8),
                    Text(translateText(ref, vi: 'Nhân bản', en: 'Duplicate')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    const Icon(Icons.archive, size: 20),
                    const SizedBox(width: 8),
                    Text(translateText(ref, vi: 'Lưu trữ', en: 'Archive')),
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
