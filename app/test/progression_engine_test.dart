import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/progression/domain/progression_engine.dart';

void main() {
  group('ProgressionEngine - XP Calculation', () {
    test('nên tính XP chuẩn cho buổi tập bình thường', () {
      final xp = ProgressionEngine.calculateXP(
        durationSeconds: 1800, // 30 phút
        completedSets: 12,
        uniqueCategories: 3,
        userStreak: 0,
        isSuspicious: false,
      );
      
      // durationXP = 30 * 2 = 60
      // volumeXP = 12 * 3 = 36
      // varietyXP = 3 * 5 = 15
      // raw = (60 + 36 + 15) * 1.0 = 111
      expect(xp, 111);
    });

    test('nên áp dụng streak multiplier chính xác', () {
      final xp = ProgressionEngine.calculateXP(
        durationSeconds: 1800,
        completedSets: 10,
        uniqueCategories: 2,
        userStreak: 10, // 10 days = 1.5x
        isSuspicious: false,
      );
      
      // raw = (60 + 30 + 10) * 1.5 = 150
      expect(xp, 150);
    });

    test('nên giới hạn XP tối đa là 500', () {
      final xp = ProgressionEngine.calculateXP(
        durationSeconds: 7200, // 120 phút -> 120 XP cap
        completedSets: 100,    // 300 XP
        uniqueCategories: 10,  // 50 XP
        userStreak: 20,       // 2.0x 
        isSuspicious: false,
      );
      
      // (120 + 300 + 50) * 2 = 940 -> cap 500
      expect(xp, 500);
    });

    test('nên trả về 10 XP nếu phát hiện gian lận (isSuspicious)', () {
      final xp = ProgressionEngine.calculateXP(
        durationSeconds: 60,
        completedSets: 20,
        uniqueCategories: 1,
        isSuspicious: true,
      );
      expect(xp, 10);
    });
  });

  group('ProgressionEngine - Anti-Cheat (Pace)', () {
    test('nên phát hiện tốc độ bất thường (Spam)', () {
      // 10 sets trong 2 phút = 5 sets/phút (> 3)
      final isSuspicious = ProgressionEngine.checkSuspiciousPace(10, 120);
      expect(isSuspicious, isTrue);
    });

    test('nên chấp nhận tốc độ tập bình thường', () {
      // 12 sets trong 30 phút = 0.4 sets/phút
      final isSuspicious = ProgressionEngine.checkSuspiciousPace(12, 1800);
      expect(isSuspicious, isFalse);
    });

    test('không nên báo suspicious nếu số sets quá ít (<= 3)', () {
      // 3 sets trong 30 giây (có thể user test app hoặc kết thúc nhanh)
      final isSuspicious = ProgressionEngine.checkSuspiciousPace(3, 30);
      expect(isSuspicious, isFalse);
    });
  });

  group('ProgressionEngine - Level Curve', () {
    test('XP yêu cầu cho Level 1 nên là 100', () {
      expect(ProgressionEngine.xpRequiredForLevel(1), 100);
    });

    test('XP yêu cầu cho Level 10 nên là 3162', () {
      expect(ProgressionEngine.xpRequiredForLevel(10), 3162);
    });
  });
}
