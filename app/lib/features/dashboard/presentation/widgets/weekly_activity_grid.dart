import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';

/// 7-day weekly activity grid (Mon–Sun / T2–CN) with Neubrutalist styling,
/// active mint highlights for completed days, and today indicator.
class WeeklyActivityGrid extends ConsumerWidget {
  final Set<int> completedWeekdays; // 1 = Monday, ..., 7 = Sunday
  final int activeDaysCount;

  const WeeklyActivityGrid({
    super.key,
    required this.completedWeekdays,
    this.activeDaysCount = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon, ..., 7 = Sun

    // Monday of the current week
    final monday = now.subtract(Duration(days: todayWeekday - 1));

    final isVi = ref.watch(localizationModeProvider) == AppLangMode.vi;
    final dayNames = isVi
        ? ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final headerTitle = translateText(
      ref,
      vi: 'HOẠT ĐỘNG TUẦN NÀY',
      en: 'WEEKLY ACTIVITY',
    );

    final summaryText = translateText(
      ref,
      vi: '$activeDaysCount ngày hoàn thành mục tiêu tuần này',
      en: '$activeDaysCount days completed this week',
    );

    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(16.0),
      backgroundColor: CandyColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CandyColors.canaryYellow,
                        shape: BoxShape.circle,
                        border: CandyColors.standardBorder(width: 1.5),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: CandyColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        headerTitle,
                        style: const TextStyle(
                          fontFamily: CandyFonts.display,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: CandyColors.ink,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CandyBadge(
                label: '$activeDaysCount/7',
                variant: CandyBadgeVariant.mint,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7 Days Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNumber = monday.add(Duration(days: index)).day;
              final weekdayIndex = index + 1; // 1..7
              final isCompleted = completedWeekdays.contains(weekdayIndex);
              final isToday = weekdayIndex == todayWeekday;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _buildDayColumn(
                    dayLabel: dayNames[index],
                    dayNumber: dayNumber,
                    isCompleted: isCompleted,
                    isToday: isToday,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Summary footer
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 15,
                color: CandyColors.charcoal,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  summaryText,
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CandyColors.charcoal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn({
    required String dayLabel,
    required int dayNumber,
    required bool isCompleted,
    required bool isToday,
  }) {
    Color indicatorBg = CandyColors.canvas;
    Color indicatorBorder = CandyColors.ink;
    Widget? indicatorChild;

    if (isCompleted) {
      indicatorBg = CandyColors.mintGreen;
      indicatorChild = const Icon(
        Icons.check_rounded,
        size: 16,
        color: CandyColors.ink,
      );
    } else if (isToday) {
      indicatorBg = CandyColors.canaryYellow;
      indicatorChild = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: CandyColors.ink,
          shape: BoxShape.circle,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day name (T2, T3... / Mon, Tue...)
        Text(
          dayLabel,
          style: TextStyle(
            fontFamily: CandyFonts.body,
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
            color: isToday ? CandyColors.hotPink : CandyColors.charcoal,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 4),

        // Indicator Box/Circle
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: indicatorBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: indicatorBorder,
              width: isToday ? 2.5 : 2.0,
            ),
            boxShadow: isCompleted || isToday
                ? CandyColors.shadowPressed()
                : null,
          ),
          alignment: Alignment.center,
          child:
              indicatorChild ??
              Text(
                '$dayNumber',
                style: const TextStyle(
                  fontFamily: CandyFonts.mono,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: CandyColors.charcoal,
                ),
              ),
        ),
        const SizedBox(height: 4),

        // Date number
        Text(
          '$dayNumber',
          style: TextStyle(
            fontFamily: CandyFonts.mono,
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
            color: isToday ? CandyColors.ink : CandyColors.muted,
          ),
        ),
      ],
    );
  }
}
