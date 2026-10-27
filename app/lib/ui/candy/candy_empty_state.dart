import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';
import 'candy_button.dart';
import 'candy_card.dart';

/// Neubrutalist empty state card featuring a vibrant icon pill,
/// bold headline, descriptive message, and an action CTA button.
class CandyEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final CandyButtonVariant actionVariant;
  final Color iconBackgroundColor;

  const CandyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionVariant = CandyButtonVariant.primary,
    this.iconBackgroundColor = CandyColors.softLilac,
  });

  @override
  Widget build(BuildContext context) {
    return CandyCard(
      shadow: CandyCardShadow.medium,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
              border: CandyColors.standardBorder(),
              boxShadow: CandyColors.shadowPressed(),
            ),
            child: Icon(icon, size: 32, color: CandyColors.ink),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: CandyColors.ink,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 14,
              color: CandyColors.charcoal,
              height: 1.45,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            CandyButton(
              label: actionLabel!,
              variant: actionVariant,
              size: CandyButtonSize.medium,
              isFullWidth: false,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
