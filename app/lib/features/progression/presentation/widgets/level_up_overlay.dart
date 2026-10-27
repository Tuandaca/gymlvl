import 'package:flutter/material.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_badge.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';

class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({
    super.key,
    required this.xpResult,
    required this.onDismiss,
  });
  final Map<String, dynamic> xpResult;
  final VoidCallback onDismiss;

  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> xpResult,
  ) => showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: const Color(0x99111111),
    builder: (context) => LevelUpOverlay(
      xpResult: xpResult,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final leveledUp = xpResult['leveledUp'] == true;
    final earnedXp = xpResult['earnedXP'] ?? 0;
    final totalXp = xpResult['totalXP'] ?? 0;
    final newLevel = xpResult['newLevel'] ?? 1;
    final newTitle = xpResult['newTitle']?.toString();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: CandyCard(
            shadow: CandyCardShadow.large,
            backgroundColor: CandyColors.card,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: leveledUp
                        ? CandyColors.canaryYellow
                        : CandyColors.mintGreen,
                    shape: BoxShape.circle,
                    border: CandyColors.standardBorder(width: 2.5),
                    boxShadow: CandyColors.shadowPressed(),
                  ),
                  child: Icon(
                    leveledUp ? Icons.auto_awesome : Icons.task_alt,
                    color: CandyColors.ink,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  leveledUp
                      ? 'THĂNG CẤP! / LEVEL UP!'
                      : 'HOÀN THÀNH / WORKOUT COMPLETE',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    color: CandyColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                if (leveledUp) ...[
                  const SizedBox(height: 12),
                  CandyBadge(
                    label: 'CẤP ĐỘ / LEVEL $newLevel',
                    variant: CandyBadgeVariant.yellow,
                    fontSize: 14.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                  ),
                  if (newTitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      newTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: CandyFonts.body,
                        color: CandyColors.hotPink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: CandyColors.mintGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: CandyColors.standardBorder(),
                      boxShadow: CandyColors.shadowPressed(),
                    ),
                    child: Text(
                      '+$earnedXp XP',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: CandyFonts.mono,
                        color: CandyColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tổng XP / Total XP: $totalXp',
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    color: CandyColors.charcoal,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                CandyButton(
                  label: 'TIẾP TỤC / CONTINUE',
                  variant: leveledUp
                      ? CandyButtonVariant.primary
                      : CandyButtonVariant.mint,
                  isFullWidth: true,
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
