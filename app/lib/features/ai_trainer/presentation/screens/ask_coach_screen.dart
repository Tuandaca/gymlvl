/// In-workout AI coaching screen.
///
/// Displays an AI-generated recommendation for the current active workout.
/// The user can accept to apply the change through existing GymLvl RPCs, or
/// dismiss it. AI is advisory: it never mutates workout data directly.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/localization_engine.dart';
import '../../../../../ui/candy/candy.dart';
import '../../../workout/presentation/providers/exercise_providers.dart';
import '../../../workout/domain/workout_set.dart';
import '../../domain/models/pt_context.dart';
import '../../domain/models/pt_recommendation.dart';
import '../../domain/services/routine_application_service.dart';
import '../providers/pt_context_provider.dart';
import '../providers/pt_recommendation_provider.dart';

/// In-workout AI coaching screen.
///
/// Shows a single recommendation derived from the current active workout
/// context. The user can accept to apply it through existing GymLvl RPCs, or
/// dismiss it.
class AskCoachScreen extends ConsumerStatefulWidget {
  const AskCoachScreen({super.key});

  @override
  ConsumerState<AskCoachScreen> createState() => _AskCoachScreenState();
}

class _AskCoachScreenState extends ConsumerState<AskCoachScreen> {
  @override
  Widget build(BuildContext context) {
    final contextAsync = ref.watch(ptContextProvider);

    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          translateText(
            ref,
            vi: 'AI COACH TRONG BUỔI TẬP',
            en: 'IN-WORKOUT AI COACH',
          ),
        ),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(contextAsync),
    );
  }

  Widget _buildBody(AsyncValue<PtContext> contextAsync) {
    return contextAsync.when(
      data: (ptx) {
        final recommendationAsync = ref.watch(ptRecommendationProvider(ptx));
        return recommendationAsync.when(
          data: (recommendation) => _buildContent(context, ptx, recommendation),
          loading: () => const CandySkeleton(height: 300, borderRadius: 18),
          error: (error, _) => _buildError(context, error.toString()),
        );
      },
      loading: () => const CandySkeleton(height: 300, borderRadius: 18),
      error: (error, _) => _buildError(context, error.toString()),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PtContext ptx,
    PtRecommendation recommendation,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disclaimer
          CandyCard(
            shadow: CandyCardShadow.small,
            padding: const EdgeInsets.all(16),
            backgroundColor: CandyColors.canvas,
            borderColor: CandyColors.muted,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: CandyColors.charcoal,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    translateText(
                      ref,
                      vi: 'Gợi ý từ AI không thay đổi dữ liệu tập luyện. Khi bạn áp dụng, mục tiêu và lịch sử tập 7 ngày sẽ được chia sẻ với dịch vụ AI đã cấu hình.',
                      en: 'AI suggestions do not change workout records. Sending a question shares your goals and 7-day workout history with the configured AI service. Stop painful activity and seek qualified guidance when needed.',
                    ),
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 12,
                      color: CandyColors.charcoal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          Text(
            translateText(ref, vi: 'TÓM TẮT', en: 'SUMMARY'),
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: CandyColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.summary,
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 15,
              color: CandyColors.ink,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Reasoning
          if (recommendation.reasoning.isNotEmpty) ...[
            Text(
              translateText(ref, vi: 'LÝ DO', en: 'REASONING'),
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: CandyColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendation.reasoning.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: CandyColors.mintGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r,
                        style: const TextStyle(
                          fontFamily: CandyFonts.body,
                          fontSize: 14,
                          color: CandyColors.ink,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if (recommendation.hasActionable) ...[
            Text(
              translateText(ref, vi: 'GỢI Ý HÀNH ĐỘNG', en: 'RECOMMENDATIONS'),
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: CandyColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendation.actionable.map(
              (r) => _buildRecommendationCard(r),
            ),
            const SizedBox(height: 16),
          ],

          // Warnings
          if (recommendation.warnings.isNotEmpty) ...[
            Text(
              translateText(ref, vi: 'CẢNH BÁO', en: 'WARNINGS'),
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: CandyColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendation.warnings.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: CandyColors.coral,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        w,
                        style: const TextStyle(
                          fontFamily: CandyFonts.body,
                          fontSize: 14,
                          color: CandyColors.ink,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Confidence
          Text(
            translateText(ref, vi: 'ĐỘ TIN CẬY', en: 'CONFIDENCE'),
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: CandyColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          CandyProgressBar(
            progress: recommendation.confidence.clamp(0.0, 1.0),
            height: 10,
            fillColor: CandyColors.mintGreen,
          ),
          const SizedBox(height: 4),
          Text(
            '${(recommendation.confidence * 100).round()}%',
            style: const TextStyle(
              fontFamily: CandyFonts.mono,
              fontSize: 12,
              color: CandyColors.charcoal,
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: CandyButton(
                  label: translateText(
                    ref,
                    vi: 'ÁP DỤNG VÀO BUỔI TẬP',
                    en: 'APPLY TO WORKOUT',
                  ),
                  variant: CandyButtonVariant.primary,
                  size: CandyButtonSize.large,
                  icon: Icons.edit_calendar,
                  onPressed: () =>
                      _showApplyDialog(context, ptx, recommendation),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CandyButton(
                  label: translateText(ref, vi: 'BỎ QUA', en: 'DISMISS'),
                  variant: CandyButtonVariant.secondary,
                  size: CandyButtonSize.large,
                  icon: Icons.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(PtRecommendationItem item) {
    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(16),
      backgroundColor: CandyColors.canvas,
      borderColor: CandyColors.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CandyColors.mintGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: CandyColors.standardBorder(),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 18,
                  color: CandyColors.mintGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.action,
                      style: const TextStyle(
                        fontFamily: CandyFonts.display,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: CandyColors.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item.exerciseName != null)
                      Text(
                        item.exerciseName!,
                        style: const TextStyle(
                          fontFamily: CandyFonts.body,
                          fontSize: 13,
                          color: CandyColors.charcoal,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (item.target.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              translateText(ref, vi: 'Mục tiêu', en: 'Target'),
              style: const TextStyle(
                fontFamily: CandyFonts.body,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: CandyColors.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            ...item.target.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 13,
                    color: CandyColors.ink,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '${(item.confidence * 100).round()}%',
            style: const TextStyle(
              fontFamily: CandyFonts.mono,
              fontSize: 12,
              color: CandyColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return CandyScaffold(
      appBar: AppBar(
        title: Text(translateText(ref, vi: 'AI COACH', en: 'AI COACH')),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: CandyErrorState(
          title: translateText(ref, vi: 'LỖI', en: 'ERROR'),
          message: error,
          retryLabel: translateText(ref, vi: 'THỬ LẠI', en: 'RETRY'),
          onRetry: () => ref.invalidate(ptRecommendationProvider),
        ),
      ),
    );
  }

  void _showApplyDialog(
    BuildContext context,
    PtContext ptx,
    PtRecommendation recommendation,
  ) {
    final actionable = recommendation.actionable;
    if (actionable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translateText(
              ref,
              vi: 'Không có gợi ý hành động nào để áp dụng.',
              en: 'No actionable recommendation to apply.',
            ),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          translateText(ref, vi: 'Xác nhận áp dụng', en: 'Confirm apply'),
        ),
        content: Text(
          translateText(
            ref,
            vi: 'Bạn có chắc muốn áp dụng gợi ý này vào buổi tập hiện tại?',
            en: 'Are you sure you want to apply this recommendation to your current workout?',
          ),
        ),
        actions: [
          CandyButton(
            label: translateText(ref, vi: 'HỦY', en: 'CANCEL'),
            variant: CandyButtonVariant.secondary,
            size: CandyButtonSize.small,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CandyButton(
            label: translateText(ref, vi: 'ÁP DỤNG', en: 'APPLY'),
            variant: CandyButtonVariant.primary,
            size: CandyButtonSize.small,
            onPressed: () {
              Navigator.of(context).pop();
              _applyRecommendation(context, ptx, actionable.first);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _applyRecommendation(
    BuildContext context,
    PtContext ptx,
    PtRecommendationItem item,
  ) async {
    final repo = ref.read(workoutRepositoryProvider);
    final service = RoutineApplicationService(repo);

    // Get the active workout to apply changes to.
    final active = await repo.getActiveWorkout();
    if (active == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translateText(
              ref,
              vi: 'Không tìm thấy buổi tập đang hoạt động.',
              en: 'No active workout found.',
            ),
          ),
        ),
      );
      return;
    }

    final result = await service.applyRecommendation(active.id, item);

    if (!mounted) return;

    if (result.applied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translateText(
              ref,
              vi: 'Đã áp dụng: ${result.message}',
              en: 'Applied: ${result.message}',
            ),
          ),
        ),
      );
      // Return to workout screen after successful apply.
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translateText(
              ref,
              vi: 'Không thể áp dụng: ${result.message}',
              en: 'Could not apply: ${result.message}',
            ),
          ),
        ),
      );
    }
  }
}
