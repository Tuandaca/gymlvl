import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';
import 'candy_button.dart';
import 'candy_card.dart';

/// Coral-accented Neubrutalist error container with prominent retry CTA.
class CandyErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const CandyErrorState({
    super.key,
    this.title = 'ĐÃ XẢY RA LỖI',
    required this.message,
    this.retryLabel = 'THỬ LẠI',
    this.onRetry,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return CandyCard(
      shadow: CandyCardShadow.medium,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CandyColors.coral,
              shape: BoxShape.circle,
              border: CandyColors.standardBorder(),
              boxShadow: CandyColors.shadowPressed(),
            ),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: CandyColors.coral,
              letterSpacing: 0.5,
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
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            CandyButton(
              label: retryLabel,
              variant: CandyButtonVariant.danger,
              size: CandyButtonSize.medium,
              isFullWidth: false,
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
