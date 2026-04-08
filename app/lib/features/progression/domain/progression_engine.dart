import 'dart:math' as math;

class ProgressionEngine {
  /// Công thức tính XP đồng bộ với Server
  static int calculateXP({
    required int durationSeconds,
    required int completedSets,
    required int uniqueCategories,
    double userStreak = 0,
    bool isSuspicious = false,
  }) {
    if (isSuspicious) return 10;

    // Base XP từ thời gian (tối đa 60p = 120 XP)
    final durationMinutes = durationSeconds ~/ 60;
    final durationXP = (durationMinutes * 2).clamp(0, 120);

    // Volume XP: 3 XP mỗi Set hoàn thành
    final volumeXP = completedSets * 3;

    // Variety XP: 5 XP mỗi loại bài tập khác nhau
    final varietyXP = uniqueCategories * 5;

    // Streak Multiplier: Tối đa 2.0x
    final streakMultiplier = (1 + userStreak * 0.05).clamp(1.0, 2.0);

    final rawXP = (durationXP + volumeXP + varietyXP) * streakMultiplier;
    
    // Giới hạn tối đa 500 XP mỗi buổi tập (Anti-cheat/Cap)
    return rawXP.floor().clamp(0, 500);
  }

  /// XP tích lũy để đạt level N
  static int xpRequiredForLevel(int level) {
    return (100 * math.pow(level, 1.5)).floor();
  }

  /// Kiểm tra ngưỡng gian lận dựa trên tốc độ tập (Pace)
  static bool checkSuspiciousPace(int sets, int durationSeconds) {
    if (sets <= 3 || durationSeconds <= 0) return false;
    final durationMinutes = durationSeconds / 60;
    final pace = sets / durationMinutes;
    return pace > 3; // > 3 sets/phút là bất thường
  }
}
