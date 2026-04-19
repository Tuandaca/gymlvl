import 'dart:math' as math;

class ProgressionEngine {
  /// Công thức tính XP đồng bộ với Server
  /// XP chỉ dựa trên: Số set hoàn thành + Đa dạng bài tập + Streak
  /// KHÔNG tính XP theo thời gian tập (để tránh XP ảo khi chưa tập xong set nào)
  static int calculateXP({
    required int durationSeconds,
    required List<dynamic> completedSets, // List<WorkoutSet>
    required int uniqueCategories,
    double userStreak = 0,
    bool isSuspicious = false,
  }) {
    if (isSuspicious) return 10;
    if (completedSets.isEmpty) return 0;

    // Volume XP: Scale động theo Effort Ratio
    double volumeXP = 0;
    for (final set in completedSets) {
      final actualWeight = (set.weightKg ?? 0).toDouble();
      final baselineWeight = (set.baselineWeightKg ?? 0).toDouble();
      
      double setXP = 5.0;
      if (baselineWeight > 0) {
        final effortRatio = actualWeight / baselineWeight;
        final safeRatio = effortRatio.clamp(0.2, 3.0);
        setXP = 5.0 * safeRatio;
      } else if (actualWeight > 0) {
        setXP = 5.0;
      }
      volumeXP += setXP;
    }

    // Variety XP: 8 XP mỗi loại bài tập khác nhau (tính từ cái thứ 2 trở đi)
    final varietyXP = math.max(0, uniqueCategories - 1) * 8;

    // Streak Multiplier: Tối đa 2.0x
    final streakMultiplier = (1 + userStreak * 0.05).clamp(1.0, 2.0);

    final rawXP = (volumeXP + varietyXP) * streakMultiplier;
    
    // Giới hạn tối đa 1000 XP mỗi buổi tập (Tăng limit vì Overload)
    return rawXP.floor().clamp(0, 1000);
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
    return pace > 4; // > 4 sets/phút mới là bất thường (nới lỏng từ 3 → 4)
  }
}

