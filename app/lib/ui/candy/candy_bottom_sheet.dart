import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

/// Neubrutalist bottom sheet with top 2px solid ink border,
/// drag handle, and optional title bar.
class CandyBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showDragHandle;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;
  final double maxHeightRatio;

  const CandyBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.onClose,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.maxHeightRatio = 0.85,
  });

  /// Static helper to display a CandyBottomSheet modal.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool isScrollControlled = true,
    double maxHeightRatio = 0.85,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x99111111),
      builder: (ctx) => CandyBottomSheet(
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        maxHeightRatio: maxHeightRatio,
        onClose: () => Navigator.of(ctx).pop(),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * maxHeightRatio;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: CandyColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        border: Border(
          top: BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
          left: BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
          right: BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) ...[
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CandyColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (title != null || showCloseButton) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: const TextStyle(
                            fontFamily: CandyFonts.display,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: CandyColors.ink,
                          ),
                        ),
                      ),
                    if (showCloseButton)
                      GestureDetector(
                        onTap: onClose ?? () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: CandyColors.canvas,
                            shape: BoxShape.circle,
                            border: CandyColors.standardBorder(width: 1.5),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: CandyColors.ink,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(color: CandyColors.ink, height: 1, thickness: 1.5),
            ],
            Flexible(
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
