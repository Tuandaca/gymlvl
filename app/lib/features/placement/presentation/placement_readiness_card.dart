import 'package:flutter/material.dart';

import 'package:app/features/placement/domain/placement_models.dart';
import 'package:app/ui/candy/candy.dart';

/// Readiness-only presentation for placement state.
///
/// This card deliberately keeps placement values in a separate lane from
/// earned RPG progression. It has no actions that award XP or unlock content.
class PlacementReadinessCard extends StatelessWidget {
  const PlacementReadinessCard({
    super.key,
    required this.state,
    this.isVietnamese = false,
    this.earnedGlobalLevel,
    this.earnedClassLevel,
  });

  final PlacementState state;
  final bool isVietnamese;
  final int? earnedGlobalLevel;
  final int? earnedClassLevel;

  String _statusLabel() {
    if (isVietnamese) {
      switch (state.status) {
        case 'confirmed':
          return 'Đã xác nhận readiness tập luyện';
        case 'provisional':
          return 'Ước tính readiness tập luyện';
        case 'unassessed':
          return 'Chưa đánh giá readiness tập luyện';
        default:
          return 'Readiness tập luyện: ${state.status}';
      }
    }
    switch (state.status) {
      case 'confirmed':
        return 'Confirmed training readiness';
      case 'provisional':
        return 'Estimated training readiness';
      case 'unassessed':
        return 'Training readiness not assessed';
      default:
        return 'Training readiness: ${state.status}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isVietnamese ? 'READINESS TẬP LUYỆN' : 'TRAINING READINESS';
    final classText = isVietnamese ? 'Readiness lớp' : 'Class readiness';
    final globalText = isVietnamese ? 'Readiness toàn cục' : 'Global readiness';
    final earnedText = isVietnamese ? 'RPG đã đạt' : 'Earned RPG';
    final nextText = isVietnamese ? 'XP thật còn lại' : 'Genuine XP to next';
    final unavailable = isVietnamese ? 'Chưa có' : 'Unavailable';
    final classLevel = state.readinessClassLevel;
    final globalLevel = state.readinessGlobalLevel;
    final hasReadiness = classLevel != null || globalLevel != null;

    return Semantics(
      container: true,
      label: '${_statusLabel()}. $title',
      child: CandyCard(
        backgroundColor: CandyColors.softLilac,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_rounded, semanticLabel: 'Readiness'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: CandyFonts.display,
                      fontSize: 18,
                      color: CandyColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _statusLabel(),
              style: const TextStyle(fontFamily: CandyFonts.body),
            ),
            if (hasReadiness) ...[
              const SizedBox(height: 14),
              _Metric(
                label: classText,
                value: classLevel?.toString() ?? unavailable,
              ),
              const SizedBox(height: 8),
              _Metric(
                label: globalText,
                value: globalLevel?.toString() ?? unavailable,
              ),
            ],
            if (earnedGlobalLevel != null || earnedClassLevel != null) ...[
              const Divider(height: 22, color: CandyColors.ink),
              Text(
                earnedText,
                style: const TextStyle(fontFamily: CandyFonts.display),
              ),
              const SizedBox(height: 4),
              Text(
                'Global ${earnedGlobalLevel ?? '—'} · Class ${earnedClassLevel ?? '—'}',
                style: const TextStyle(fontFamily: CandyFonts.mono),
              ),
            ],
            if (state.readinessXpToNextGlobalLevel != null ||
                state.readinessXpToNextClassLevel != null) ...[
              const SizedBox(height: 10),
              Text(
                '$nextText: ${state.readinessXpToNextGlobalLevel ?? state.readinessXpToNextClassLevel}',
                style: const TextStyle(fontFamily: CandyFonts.body),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontFamily: CandyFonts.body)),
      Text(
        value,
        style: const TextStyle(fontFamily: CandyFonts.display, fontSize: 22),
      ),
    ],
  );
}
