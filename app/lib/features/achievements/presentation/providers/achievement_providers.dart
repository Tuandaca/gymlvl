import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../progression/presentation/providers/player_progression_view_provider.dart';
import '../../domain/achievement.dart';

part 'achievement_providers.g.dart';

/// All catalogue achievements with their earned/locked state for the current user.
@riverpod
class AchievementsController extends _$AchievementsController {
  @override
  FutureOr<List<Achievement>> build() async {
    final progression = await ref.watch(playerProgressionViewProvider.future);
    if (progression == null) return [];

    final earnedById = <String, DateTime>{};
    for (final summary in progression.achievements) {
      earnedById[summary.achievementId] = summary.unlockedAt;
    }

    return AchievementCatalog.ids.map((id) {
      final unlockedAt = earnedById[id];
      return Achievement(
        achievementId: id,
        title: AchievementCatalog.titleOf(id),
        description: AchievementCatalog.descOf(id),
        unlockedAt: unlockedAt,
        isEarned: earnedById.containsKey(id),
      );
    }).toList()..sort((a, b) {
      // Earned achievements first, then by catalogue order.
      if (a.isEarned && !b.isEarned) return -1;
      if (!a.isEarned && b.isEarned) return 1;
      return AchievementCatalog.ids
          .indexOf(a.achievementId)
          .compareTo(AchievementCatalog.ids.indexOf(b.achievementId));
    });
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
