import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

/// Tactile Neubrutalist bottom navigation / rail item with active pill indicator.
class CandyNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final String? badgeText;

  const CandyNavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor = CandyColors.canaryYellow,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: CandyTimings.press,
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: CandyColors.pillBorderRadius,
                  border: isSelected
                      ? CandyColors.standardBorder(width: 1.5)
                      : Border.all(color: Colors.transparent, width: 1.5),
                  boxShadow: isSelected ? CandyColors.shadowPressed() : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: isSelected
                          ? CandyColors.ink
                          : CandyColors.charcoal,
                    ),
                    if (badgeText != null)
                      Positioned(
                        top: -4,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: CandyColors.hotPink,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: CandyColors.ink,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            badgeText!,
                            style: const TextStyle(
                              fontFamily: CandyFonts.mono,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: CandyFonts.body,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? CandyColors.ink : CandyColors.muted,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
