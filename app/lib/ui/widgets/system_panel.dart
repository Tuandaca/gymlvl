import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SystemPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurRadius;
  final bool glow;

  const SystemPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.margin,
    this.blurRadius = 16.0,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Stack(
        children: [
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppTheme.panelBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.cyanNeon.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: glow ? [
                BoxShadow(
                  color: AppTheme.cyanNeon.withOpacity(0.15),
                  blurRadius: blurRadius,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                )
              ] : [],
            ),
            child: child,
          ),
          // Corner decorators
          Positioned(top: 0, left: 0, child: _buildCorner(isTopLeft: true)),
          Positioned(top: 0, right: 0, child: _buildCorner(isTopRight: true)),
          Positioned(bottom: 0, left: 0, child: _buildCorner(isBottomLeft: true)),
          Positioned(bottom: 0, right: 0, child: _buildCorner(isBottomRight: true)),
        ],
      ),
    );
  }

  Widget _buildCorner({
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: isTopLeft || isTopRight ? const BorderSide(color: AppTheme.cyanNeon, width: 2) : BorderSide.none,
          bottom: isBottomLeft || isBottomRight ? const BorderSide(color: AppTheme.cyanNeon, width: 2) : BorderSide.none,
          left: isTopLeft || isBottomLeft ? const BorderSide(color: AppTheme.cyanNeon, width: 2) : BorderSide.none,
          right: isTopRight || isBottomRight ? const BorderSide(color: AppTheme.cyanNeon, width: 2) : BorderSide.none,
        ),
      ),
    );
  }
}
