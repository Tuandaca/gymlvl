import 'package:flutter/material.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_badge.dart';
import '../../../../ui/candy/candy_card.dart';

/// Read-only RPE / RIR display chip pair.
///
/// RPE (1-10) and RIR (0-10) are nullable on ``WorkoutSet``; a null value
/// renders as an em dash so the UI never invents a number the server did not
/// record. No client-side persistence of RPE/RIR happens here.
class RpeRirTile extends StatelessWidget {
  /// Rating of Perceived Exertion (1-10), null when not recorded.
  final int? rpe;

  /// Reps In Reserve (0-10), null when not recorded.
  final int? rir;

  const RpeRirTile({super.key, this.rpe, this.rir});

  @override
  Widget build(BuildContext context) {
    return CandyCard(
      shadow: CandyCardShadow.none,
      borderColor: CandyColors.gridLine,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _metricChip(
            'RPE',
            rpe,
            rpe != null && rpe! >= 8 ? CandyColors.hotPink : null,
          ),
          if (rir != null) ...[
            const SizedBox(width: 8.0),
            _metricChip('RIR', rir, null),
          ],
          if (rpe == null && rir == null) ...[
            const SizedBox(width: 8.0),
            _metricChip('RPE', null, null),
          ],
        ],
      ),
    );
  }

  Widget _metricChip(String label, int? value, Color? accent) {
    final displayValue = value ?? -1;
    final semanticsLabel = value == null
        ? '$label not recorded'
        : '$label $displayValue';
    return Semantics(
      label: semanticsLabel,
      child: Container(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        child: CandyBadge(
          label: '$label ${value ?? '—'}',
          variant: CandyBadgeVariant.card,
          customColor: accent ?? CandyColors.card,
          textColor: CandyColors.ink,
          fontSize: 11.0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        ),
      ),
    );
  }
}
