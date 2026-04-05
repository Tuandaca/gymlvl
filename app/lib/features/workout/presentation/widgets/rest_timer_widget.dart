import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../ui/theme/app_theme.dart';

class RestTimerWidget extends StatelessWidget {
  final int secondsRemaining;
  final int secondsTotal;
  final VoidCallback onSkip;
  final VoidCallback? onAddTime;

  const RestTimerWidget({
    super.key,
    required this.secondsRemaining,
    required this.secondsTotal,
    required this.onSkip,
    this.onAddTime,
  });

  double get progress {
    if (secondsTotal == 0) return 0;
    return 1.0 - (secondsRemaining / secondsTotal);
  }

  String get formattedTime {
    final m = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanNeon.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textDim.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'NGHỈ GIỮA HIỆP',
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: AppTheme.cyanNeon,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              shadows: [
                Shadow(color: AppTheme.cyanNeon.withOpacity(0.5), blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Circular progress timer
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _CircularTimerPainter(
                progress: progress,
                progressColor: AppTheme.cyanNeon,
                backgroundColor: AppTheme.cyanNeon.withOpacity(0.1),
                strokeWidth: 8,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: AppTheme.cyanNeon,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppTheme.cyanNeon.withOpacity(0.6),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'còn lại',
                      style: TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 32),

          // Quick-select buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickButton(context, '+15s', () {
                onAddTime?.call();
                HapticFeedback.lightImpact();
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Skip button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onSkip();
              },
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text(
                'BỎ QUA',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.dangerOrange,
                side: BorderSide(color: AppTheme.dangerOrange.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
      BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cyanNeon.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.cyanNeon,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Quick-select modal hiện trước khi start timer
class RestTimerQuickSelect extends StatelessWidget {
  final ValueChanged<int> onSelect;

  const RestTimerQuickSelect({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textDim.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'CHỌN THỜI GIAN NGHỈ',
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: AppTheme.cyanNeon,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeOption(context, 30, '30s'),
              _buildTimeOption(context, 60, '1:00'),
              _buildTimeOption(context, 90, '1:30'),
              _buildTimeOption(context, 120, '2:00'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(BuildContext context, int seconds, String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pop();
        onSelect(seconds);
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppTheme.panelBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cyanNeon.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              color: AppTheme.cyanNeon,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Circular Timer Painter ───

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularTimerPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Neon glow effect
    final glowPaint = Paint()
      ..color = progressColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final sweepAngle = 2 * pi * progress;
    const startAngle = -pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
