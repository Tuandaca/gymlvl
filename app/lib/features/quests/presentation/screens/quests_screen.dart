import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/localization_engine.dart';
import '../providers/quest_providers.dart';
import '../widgets/daily_quest_card.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questState = ref.watch(activeQuestControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'quests_title'.tr(ref),
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(activeQuestControllerProvider.notifier).refresh();
        },
        color: AppTheme.cyanNeon,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'mainframe_objectives'.tr(ref),
                style: const TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              questState.when(
                data: (quest) => quest != null
                    ? DailyQuestCard(quest: quest)
                    : _buildEmptyQuests(ref),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: AppTheme.cyanNeon),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(height: 32),
              _buildComingSoonSection('main_quest'.tr(ref), ref),
              const SizedBox(height: 16),
              _buildComingSoonSection('hidden_quest'.tr(ref), ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyQuests(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.query_builder_rounded, color: AppTheme.textDim, size: 48),
          const SizedBox(height: 16),
          Text(
            'no_missions'.tr(ref),
            style: const TextStyle(
              color: AppTheme.textMain,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_missions_desc'.tr(ref),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonSection(String title, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppTheme.textDim, fontWeight: FontWeight.bold),
          ),
          Text(
            'locked'.tr(ref),
            style: const TextStyle(
              color: AppTheme.dangerOrange,
              fontSize: 10,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
