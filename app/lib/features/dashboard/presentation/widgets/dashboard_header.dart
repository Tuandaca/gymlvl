import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../../../onboarding/domain/class_definitions.dart';

/// Personalized greeting, user avatar/level badge, and RPG class indicator
/// styled with tactile Candy Neubrutalism 2px ink borders and hard shadows.
class DashboardHeader extends ConsumerWidget {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> userClasses;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.userClasses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = (user['display_name'] as String?)?.trim();
    final effectiveName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : 'Hunter';
    final title = (user['current_title'] as String?) ?? 'Seeker';
    final level = (user['level'] as num?)?.toInt() ?? 1;

    // Greeting text with full VI/EN localization
    final greeting = translateText(
      ref,
      vi: 'Sẵn sàng chiến thôi, $effectiveName!',
      en: 'Ready to conquer, $effectiveName!',
    );

    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(16.0),
      backgroundColor: CandyColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tactile Neubrutalist Avatar with level badge pill
              _buildAvatar(effectiveName, level),
              const SizedBox(width: 14),

              // Personalized Greeting and User Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontFamily: CandyFonts.display,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: CandyColors.ink,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.military_tech_rounded,
                          size: 16,
                          color: CandyColors.charcoal,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: CandyFonts.body,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
              ),
            ],
          ),

          // RPG Classes row
          if (userClasses.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: CandyColors.ink, thickness: 1.5, height: 1.5),
            const SizedBox(height: 12),
            _buildClassesList(context, ref),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, int level) {
    final initials = name.isNotEmpty
        ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase()
        : 'GY';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: CandyColors.canaryYellow,
            shape: BoxShape.circle,
            border: CandyColors.standardBorder(width: 2.0),
            boxShadow: CandyColors.shadowPressed(),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: CandyColors.ink,
            ),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: CandyColors.hotPink,
              borderRadius: BorderRadius.circular(999),
              border: CandyColors.standardBorder(width: 1.5),
            ),
            child: Text(
              'L$level',
              style: const TextStyle(
                fontFamily: CandyFonts.mono,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassesList(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: userClasses.map((item) {
        final classId = item['class_id']?.toString() ?? '';
        final classLevel = (item['level'] as num?)?.toInt() ?? 1;
        final slot = item['slot']?.toString() ?? 'primary';
        final isPrimary = slot == 'primary';
        final definition = kClassDefinitions[classId];

        final localizedName = definition != null
            ? resolveClassName(definition, ref.watch(localizationModeProvider))
            : classId;

        final badgeColor = isPrimary
            ? CandyColors.mintGreen
            : CandyColors.softLilac;

        return CandyBadge(
          label: '$localizedName · L$classLevel',
          icon: isPrimary ? Icons.shield_rounded : Icons.auto_awesome_rounded,
          customColor: badgeColor,
          textColor: CandyColors.ink,
          hasShadow: true,
          fontSize: 12,
        );
      }).toList(),
    );
  }
}
