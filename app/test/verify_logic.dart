import 'dart:math' as math;
import '../lib/features/progression/domain/progression_engine.dart';

void main() {
  print('--- DART PROGRESSION ENGINE TEST ---');
  
  final xp1 = ProgressionEngine.calculateXP(
    durationSeconds: 1800,
    completedSets: 12,
    uniqueCategories: 3,
  );
  print('Normal Workout XP: $xp1 (Expected: 111)');
  
  final suspicious = ProgressionEngine.checkSuspiciousPace(10, 60);
  print('Suspicious Pace (10 sets/1min): $suspicious (Expected: true)');
  
  final xp2 = ProgressionEngine.calculateXP(
    durationSeconds: 1800,
    completedSets: 12,
    uniqueCategories: 3,
    isSuspicious: true,
  );
  print('Suspicious Workout XP: $xp2 (Expected: 10)');
  
  print('Level 10 XP Required: ${ProgressionEngine.xpRequiredForLevel(10)} (Expected: 3162)');
  
  print('--- TEST COMPLETE ---');
}
