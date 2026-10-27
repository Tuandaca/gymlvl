import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';
import 'candy_button.dart';

/// Tactile Neubrutalist modal dialog with 2px ink border and large hard drop shadow.
class CandyDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final IconData? icon;
  final Color iconBackgroundColor;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final CandyButtonVariant primaryVariant;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final List<Widget>? customActions;

  const CandyDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.icon,
    this.iconBackgroundColor = CandyColors.canaryYellow,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.primaryVariant = CandyButtonVariant.primary,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.customActions,
  });

  /// Static helper to display a CandyDialog in a showDialog modal.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    IconData? icon,
    Color iconBackgroundColor = CandyColors.canaryYellow,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    CandyButtonVariant primaryVariant = CandyButtonVariant.primary,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: const Color(0x99111111),
      builder: (ctx) => CandyDialog(
        title: title,
        message: message,
        content: content,
        icon: icon,
        iconBackgroundColor: iconBackgroundColor,
        primaryActionLabel: primaryActionLabel,
        onPrimaryAction: onPrimaryAction ?? () => Navigator.of(ctx).pop(),
        primaryVariant: primaryVariant,
        secondaryActionLabel: secondaryActionLabel,
        onSecondaryAction: onSecondaryAction ?? () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: CandyColors.card,
          borderRadius: CandyColors.cardBorderRadius,
          border: CandyColors.standardBorder(),
          boxShadow: CandyColors.shadowLarge(),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                    border: CandyColors.standardBorder(),
                    boxShadow: CandyColors.shadowPressed(),
                  ),
                  child: Icon(icon, color: CandyColors.ink, size: 28),
                ),
              ),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: CandyColors.ink,
                letterSpacing: 0.3,
                height: 1.25,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: CandyFonts.body,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: CandyColors.charcoal,
                  height: 1.4,
                ),
              ),
            ],
            if (content != null) ...[const SizedBox(height: 16), content!],
            const SizedBox(height: 24),
            if (customActions != null)
              ...customActions!
            else
              Row(
                children: [
                  if (secondaryActionLabel != null) ...[
                    Expanded(
                      child: CandyButton(
                        label: secondaryActionLabel!,
                        variant: CandyButtonVariant.neutral,
                        size: CandyButtonSize.medium,
                        onPressed:
                            onSecondaryAction ??
                            () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (primaryActionLabel != null)
                    Expanded(
                      child: CandyButton(
                        label: primaryActionLabel!,
                        variant: primaryVariant,
                        size: CandyButtonSize.medium,
                        onPressed:
                            onPrimaryAction ??
                            () => Navigator.of(context).pop(),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
