import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
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
        title: const Text(
          'NHIỆM VỤ',
          style: TextStyle(
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
              const Text(
                'MAINFRAME OBJECTIVES',
                style: TextStyle(
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
                    : _buildEmptyQuests(),
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
              _buildComingSoonSection('QUEST CHÍNH TUYẾN'),
              const SizedBox(height: 16),
              _buildComingSoonSection('NHIỆM VỤ ẨN'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyQuests() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(Icons.query_builder_rounded, color: AppTheme.textDim, size: 48),
          const SizedBox(height: 16),
          Text(
            'NO MISSIONS ASSIGNED',
            style: TextStyle(
              color: AppTheme.textMain,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new objectives or force sync manually.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonSection(String title) {
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
          const Text(
            'LOCKED',
            style: TextStyle(
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
