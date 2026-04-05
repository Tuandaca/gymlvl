import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SystemButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SystemButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SystemButton> createState() => _SystemButtonState();
}

class _SystemButtonState extends State<SystemButton> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.onPressed != null && _isHovered ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutQuart,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.cyanNeon, AppTheme.purpleNeon],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.cyanNeon.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: widget.onPressed == null ? null : [
            BoxShadow(
              color: AppTheme.purpleNeon.withOpacity(_isHovered ? 0.6 : 0.4),
              blurRadius: _isHovered ? 20 : 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppTheme.cyanNeon.withOpacity(_isHovered ? 0.6 : 0.4),
              blurRadius: _isHovered ? 20 : 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            onHover: (value) => setState(() => _isHovered = value),
            onHighlightChanged: (value) => setState(() => _isHovered = value),
            borderRadius: BorderRadius.circular(8),
            splashColor: AppTheme.background.withOpacity(0.3),
            highlightColor: AppTheme.background.withOpacity(0.1),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: const [
                                Colors.white,
                                Colors.white,
                                Color(0xFFE0FFFF), // Light cyan shimmer
                                Colors.white,
                                Colors.white,
                              ],
                              stops: [
                                0.0,
                                _shimmerController.value - 0.2,
                                _shimmerController.value,
                                _shimmerController.value + 0.2,
                                1.0,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            widget.text.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
