import 'package:flutter/material.dart';

class LevelUpOverlay extends StatelessWidget {
  final Map<String, dynamic> xpResult;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.xpResult,
    required this.onDismiss,
  });

  static Future<void> show(BuildContext context, Map<String, dynamic> xpResult) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpOverlay(
        xpResult: xpResult,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final earnedXP = xpResult['earnedXP'] ?? 0;
    final totalXP = xpResult['totalXP'] ?? 0;
    final leveledUp = xpResult['leveledUp'] == true;
    final newLevel = xpResult['newLevel'] ?? 1;
    final newTitle = xpResult['newTitle'];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C), // Dark theme surface
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: leveledUp ? Colors.amber : const Color(0xFF00E5FF),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (leveledUp ? Colors.amber : const Color(0xFF00E5FF)).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leveledUp) ...[
              const Icon(Icons.star, color: Colors.amber, size: 64),
              const SizedBox(height: 16),
              const Text(
                'LEVEL UP!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level $newLevel',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (newTitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  newTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ] else ...[
              const Icon(Icons.bolt, color: Color(0xFF00E5FF), size: 64),
              const SizedBox(height: 16),
              const Text(
                'WORKOUT COMPLETE',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E5FF),
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '+',
                    style: TextStyle(fontSize: 24, color: Colors.greenAccent),
                  ),
                  Text(
                    '$earnedXP',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'XP',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total XP: $totalXP',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: leveledUp ? Colors.amber : const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'TIẾP TỤC',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
