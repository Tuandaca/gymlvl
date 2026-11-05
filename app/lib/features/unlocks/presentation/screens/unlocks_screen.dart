import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../providers/unlock_providers.dart';
import '../widgets/unlock_card.dart';

class UnlocksScreen extends ConsumerWidget {
  const UnlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUnlocks = ref.watch(unlocksControllerProvider);

    return CandyScaffold(
      gridBackground: true,
      appBar: AppBar(
        title: Text(
          'unlocks_title'.tr(ref),
          style: const TextStyle(
            fontFamily: CandyFonts.display,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: CandyColors.ink,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: CandyColors.ink, height: 2.0),
        ),
      ),
      body: RefreshIndicator(
        color: CandyColors.hotPink,
        onRefresh: () => ref.read(unlocksControllerProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 920
                ? (constraints.maxWidth - 880) / 2
                : (constraints.maxWidth < 360 ? 12.0 : 16.0);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              children: [
                asyncUnlocks.when(
                  data: (unlocks) {
                    final unlocked = unlocks.where((u) => u.isUnlocked).length;
                    final total = unlocks.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CandyStatTile(
                                label: translateText(
                                  ref,
                                  vi: 'Tổng mở khóa',
                                  en: 'Total unlocks',
                                ),
                                value: total.toString(),
                                icon: Icons.lock_outline_rounded,
                                accentColor: CandyColors.canaryYellow,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CandyStatTile(
                                label: translateText(
                                  ref,
                                  vi: 'Đã mở khóa',
                                  en: 'Unlocked',
                                ),
                                value: unlocked.toString(),
                                icon: Icons.lock_open_rounded,
                                accentColor: CandyColors.mintGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: CandyColors.softLilac,
                                shape: BoxShape.circle,
                                border: CandyColors.standardBorder(width: 1.5),
                              ),
                              child: const Icon(
                                Icons.lock_open_rounded,
                                size: 14,
                                color: CandyColors.ink,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                translateText(
                                  ref,
                                  vi: 'Mở khóa',
                                  en: 'Unlocks',
                                ),
                                style: const TextStyle(
                                  fontFamily: CandyFonts.display,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: CandyColors.ink,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (unlocks.isEmpty)
                          CandyEmptyState(
                            icon: Icons.lock_outline,
                            title: translateText(
                              ref,
                              vi: 'Chưa có mở khóa nào.',
                              en: 'No unlocks yet.',
                            ),
                            message: translateText(
                              ref,
                              vi: 'Huấn luyện để đạt cấp độ và thành tích, mở khóa huy hiệu và danh hiệu.',
                              en: 'Train to reach levels and milestones, unlocking badges and titles.',
                            ),
                          )
                        else
                          ...unlocks.map(
                            (u) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: UnlockCard(unlock: u, ref: ref),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () =>
                      const CandySkeleton(height: 300, borderRadius: 18),
                  error: (_, _) => CandyErrorState(
                    message: 'load_failed'.tr(ref),
                    onRetry: () =>
                        ref.read(unlocksControllerProvider.notifier).refresh(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
