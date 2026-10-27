import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.icon = Icons.info_outline,
  });
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.panelBackground,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.cyanNeon, size: 32),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textMain, height: 1.5),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(retryLabel ?? 'Retry'),
          ),
        ],
      ],
    ),
  );
}
