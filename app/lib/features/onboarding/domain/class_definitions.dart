/// Static data definitions for the RPG Class system.
/// Maps to the `class_definitions` and `class_synergies` tables in Supabase.
/// Used client-side to avoid unnecessary DB queries for static data.

import 'dart:math' as math;

class ClassDefinition {
  final String classId;
  final String className;
  final String focus;
  final String difficulty; // 'easy', 'medium', 'hard', 'hardcore'
  final int graduationXp;
  final int xpBase;
  final double xpSlope;
  final String iconEmoji;
  final int colorHex;

  const ClassDefinition({
    required this.classId,
    required this.className,
    required this.focus,
    required this.difficulty,
    required this.graduationXp,
    required this.xpBase,
    required this.xpSlope,
    required this.iconEmoji,
    required this.colorHex,
  });

  /// Total XP required to reach a given level for this class.
  /// Formula: Total_XP = base * (level ^ slope)
  int totalXpForLevel(int level) {
    if (level <= 1) return 0;
    return (xpBase * math.pow(level.toDouble(), xpSlope)).floor();
  }

  /// Interval XP from current level to next level.
  int intervalXp(int level) {
    return totalXpForLevel(level + 1) - totalXpForLevel(level);
  }
}

/// All 8 class definitions from CLASS_SYSTEM_SPEC.md
const Map<String, ClassDefinition> kClassDefinitions = {
  'A': ClassDefinition(
    classId: 'A', className: 'Fat Slayer', focus: 'Đa dạng, Cardio, Pace',
    difficulty: 'easy', graduationXp: 6000, xpBase: 80, xpSlope: 1.40,
    iconEmoji: '⚡', colorHex: 0xFFFF6D00,
  ),
  'B': ClassDefinition(
    classId: 'B', className: 'Recomp Ghost', focus: 'Variety + Volume',
    difficulty: 'medium', graduationXp: 8500, xpBase: 100, xpSlope: 1.45,
    iconEmoji: '👻', colorHex: 0xFF7C4DFF,
  ),
  'C': ClassDefinition(
    classId: 'C', className: 'Mass Architect', focus: 'Volume, Reps (8-12)',
    difficulty: 'hard', graduationXp: 11000, xpBase: 130, xpSlope: 1.55,
    iconEmoji: '🏗️', colorHex: 0xFF00E676,
  ),
  'D': ClassDefinition(
    classId: 'D', className: 'Titan Strength', focus: 'Trọng lượng (Weight)',
    difficulty: 'hard', graduationXp: 12000, xpBase: 130, xpSlope: 1.55,
    iconEmoji: '🛡️', colorHex: 0xFFFF1744,
  ),
  'E': ClassDefinition(
    classId: 'E', className: 'Nitro Athlete', focus: 'Tốc độ, Bộc phát',
    difficulty: 'medium', graduationXp: 9000, xpBase: 100, xpSlope: 1.45,
    iconEmoji: '🏃', colorHex: 0xFF00E5FF,
  ),
  'F': ClassDefinition(
    classId: 'F', className: 'Enduro Guard', focus: 'Số hiệp cao, Nghỉ ngắn',
    difficulty: 'easy', graduationXp: 7000, xpBase: 80, xpSlope: 1.40,
    iconEmoji: '🔋', colorHex: 0xFF76FF03,
  ),
  'G': ClassDefinition(
    classId: 'G', className: 'Gravity Defier', focus: 'Kỹ thuật Bodyweight',
    difficulty: 'medium', graduationXp: 9000, xpBase: 100, xpSlope: 1.45,
    iconEmoji: '🧘', colorHex: 0xFFE040FB,
  ),
  'H': ClassDefinition(
    classId: 'H', className: 'Apex Competitor', focus: 'Tỉ lệ, Đối xứng, Khắt khe',
    difficulty: 'hardcore', graduationXp: 15000, xpBase: 160, xpSlope: 1.65,
    iconEmoji: '👑', colorHex: 0xFFFFD600,
  ),
};

/// Synergy pairs — defines which class combos unlock bonuses
class ClassSynergy {
  final String primaryClassId;
  final String secondaryClassId;
  final String synergyName;
  final int bonusPercent;
  final bool isPerfect;

  const ClassSynergy({
    required this.primaryClassId,
    required this.secondaryClassId,
    required this.synergyName,
    this.bonusPercent = 5,
    this.isPerfect = false,
  });
}

const List<ClassSynergy> kPerfectSynergies = [
  ClassSynergy(primaryClassId: 'A', secondaryClassId: 'B', synergyName: 'The Shredder', bonusPercent: 5, isPerfect: true),
  ClassSynergy(primaryClassId: 'C', secondaryClassId: 'D', synergyName: 'Juggernaut', bonusPercent: 5, isPerfect: true),
  ClassSynergy(primaryClassId: 'G', secondaryClassId: 'D', synergyName: 'Cyber Monk', bonusPercent: 5, isPerfect: true),
  ClassSynergy(primaryClassId: 'E', secondaryClassId: 'F', synergyName: 'First Responder', bonusPercent: 5, isPerfect: true),
];

/// Get the synergy info for a class pair (bidirectional lookup)
ClassSynergy? getSynergyForPair(String classA, String classB) {
  for (final s in kPerfectSynergies) {
    if ((s.primaryClassId == classA && s.secondaryClassId == classB) ||
        (s.primaryClassId == classB && s.secondaryClassId == classA)) {
      return s;
    }
  }
  return null;
}

/// Get recommended secondary classes for a given primary
List<String> getRecommendedSecondary(String primaryClassId) {
  switch (primaryClassId) {
    case 'A': return ['B', 'C'];        // Fat Loss → Recomp or Hypertrophy
    case 'B': return ['A', 'C'];        // Recomp → Fat Loss or Hypertrophy
    case 'C': return ['D', 'F', 'B'];   // Hypertrophy → Strength, Endurance, or Recomp
    case 'D': return ['C', 'G'];        // Strength → Hypertrophy or Calisthenic
    case 'E': return ['F'];             // Functional → Endurance
    case 'F': return ['E'];             // Endurance → Functional
    case 'G': return ['D'];             // Calisthenics → Strength
    case 'H': return ['C', 'D'];        // Bodybuilding → Hypertrophy or Strength
    default:  return [];
  }
}
