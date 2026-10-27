import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/widgets/status_panel.dart';
import '../providers/quest_providers.dart';
import '../widgets/daily_quest_card.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quest = ref.watch(activeQuestControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text('quests_title'.tr(ref))),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(activeQuestControllerProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 760
                  ? (constraints.maxWidth - 720) / 2
                  : (constraints.maxWidth < 360 ? 12 : 20),
              vertical: (constraints.maxWidth < 360 ? 12 : 20),
            ),
            children: [
              quest.when(
                data: (value) => value == null
                    ? StatusPanel(
                        message: 'rest_day'.tr(ref),
                        icon: Icons.nights_stay_outlined,
                      )
                    : DailyQuestCard(quest: value),
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => StatusPanel(
                  message: 'load_failed'.tr(ref),
                  retryLabel: 'retry'.tr(ref),
                  onRetry: () => ref.invalidate(activeQuestControllerProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
