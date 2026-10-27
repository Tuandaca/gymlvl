import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

enum CandyButtonVariant { primary, secondary, mint, lilac, danger, neutral }

enum CandyButtonSize { small, medium, large }

/// Tactile Neubrutalist button with 80-140ms press animation,
/// downward-right offset translation, and hard shadow collapse.
class CandyButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final CandyButtonVariant variant;
  final CandyButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;

  const CandyButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.variant = CandyButtonVariant.primary,
    this.size = CandyButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
  }) : assert(
         label != null || child != null,
         'Either label or child must be provided',
       );

  @override
  State<CandyButton> createState() => _CandyButtonState();
}

class _CandyButtonState extends State<CandyButton> {
  bool _isPressed = false;

  Color _getBackgroundColor() {
    switch (widget.variant) {
      case CandyButtonVariant.primary:
        return CandyColors.hotPink;
      case CandyButtonVariant.secondary:
        return CandyColors.canaryYellow;
      case CandyButtonVariant.mint:
        return CandyColors.mintGreen;
      case CandyButtonVariant.lilac:
        return CandyColors.softLilac;
      case CandyButtonVariant.danger:
        return CandyColors.coral;
      case CandyButtonVariant.neutral:
        return CandyColors.card;
    }
  }

  Color _getTextColor() {
    switch (widget.variant) {
      case CandyButtonVariant.primary:
      case CandyButtonVariant.danger:
        return Colors.white;
      case CandyButtonVariant.secondary:
      case CandyButtonVariant.mint:
      case CandyButtonVariant.lilac:
      case CandyButtonVariant.neutral:
        return CandyColors.ink;
    }
  }

  double _getMinHeight() {
    if (widget.height != null) return widget.height!;
    switch (widget.size) {
      case CandyButtonSize.small:
        return 48.0; // Meets 48dp minimum touch target
      case CandyButtonSize.medium:
        return 52.0;
      case CandyButtonSize.large:
        return 58.0;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case CandyButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
      case CandyButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case CandyButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case CandyButtonSize.small:
        return 13.0;
      case CandyButtonSize.medium:
        return 15.0;
      case CandyButtonSize.large:
        return 17.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final bgColor = isEnabled
        ? _getBackgroundColor()
        : _getBackgroundColor().withValues(alpha: 0.5);
    final textColor = isEnabled
        ? _getTextColor()
        : _getTextColor().withValues(alpha: 0.6);
    final minHeight = _getMinHeight();

    // Tactile translation & shadow
    final currentOffset = _isPressed && isEnabled
        ? CandyColors.pressTranslation
        : Offset.zero;
    final currentShadow = _isPressed && isEnabled
        ? CandyColors.shadowPressed()
        : CandyColors.shadowSmall();

    Widget content;
    if (widget.isLoading) {
      content = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else if (widget.child != null) {
      content = widget.child!;
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: _getFontSize() + 4, color: textColor),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.label!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    Widget buttonWidget = Transform.translate(
      offset: currentOffset,
      child: AnimatedContainer(
        duration: CandyTimings.press,
        curve: Curves.easeInOut,
        constraints: BoxConstraints(
          minHeight: minHeight,
          minWidth: widget.width ?? (widget.isFullWidth ? double.infinity : 0),
        ),
        padding: _getPadding(),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: CandyColors.buttonBorderRadius,
          border: CandyColors.standardBorder(),
          boxShadow: isEnabled ? currentShadow : [],
        ),
        child: Center(child: content),
      ),
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled
            ? () => setState(() => _isPressed = false)
            : null,
        child: widget.isFullWidth
            ? SizedBox(width: double.infinity, child: buttonWidget)
            : buttonWidget,
      ),
    );
  }
}
