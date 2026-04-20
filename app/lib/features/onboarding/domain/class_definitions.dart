/// Static data definitions for the RPG Class system.
/// Maps to the `class_definitions` and `class_synergies` tables in Supabase.
/// Used client-side to avoid unnecessary DB queries for static data.

import 'dart:math' as math;

class ClassDefinition {
  final String classId;
  final String classNameVI;
  final String classNameEN;
  final String focusVI;
  final String focusEN;
  final String descriptionVI;
  final String descriptionEN;
  final String difficulty; // 'easy', 'medium', 'hard', 'hardcore'
  final int graduationXp;
  final int xpBase;
  final double xpSlope;
  final String iconEmoji;
  final int colorHex;

  const ClassDefinition({
    required this.classId,
    required this.classNameVI,
    required this.classNameEN,
    required this.focusVI,
    required this.focusEN,
    required this.descriptionVI,
    required this.descriptionEN,
    required this.difficulty,
    required this.graduationXp,
    required this.xpBase,
    required this.xpSlope,
    required this.iconEmoji,
    required this.colorHex,
  });

  // Backward compat: default to EN
  String get className => classNameEN;
  String get focus => focusEN;

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

/// ═══════════════════════════════════════════════════════════════
/// 6 Hệ Phái Chính — Goal-Oriented Class System
/// ═══════════════════════════════════════════════════════════════
const Map<String, ClassDefinition> kClassDefinitions = {
  // ─── A: Giảm Cân / Weight Loss ───
  'A': ClassDefinition(
    classId: 'A',
    classNameVI: 'Sát Thủ Mỡ',
    classNameEN: 'Shredder',
    focusVI: 'Cardio cường độ cao, tạ nhẹ, nghỉ ngắn',
    focusEN: 'High-intensity cardio, light weights, short rests',
    descriptionVI: 'Kết hợp HIIT và tạ nhẹ để đốt cháy mỡ thừa tối đa. Phù hợp cho người muốn giảm cân nhanh và cải thiện thể lực tổng thể.',
    descriptionEN: 'Combines HIIT and light weights to maximize fat burning. Perfect for rapid weight loss and overall fitness improvement.',
    difficulty: 'easy',
    graduationXp: 6000,
    xpBase: 80,
    xpSlope: 1.40,
    iconEmoji: '🔥',
    colorHex: 0xFFFF6D00, // Orange fire
  ),

  // ─── B: Tăng Cơ / Hypertrophy ───
  'B': ClassDefinition(
    classId: 'B',
    classNameVI: 'Kiến Tạo Cơ',
    classNameEN: 'Hiper-Growth',
    focusVI: 'Tạ trung bình, 8-12 rep, tập trung kích thích cơ',
    focusEN: 'Moderate weight, 8-12 reps, muscle stimulation focus',
    descriptionVI: 'Tập trung vào khối lượng tạ vừa phải và số Rep 8-12 để kích thích sự phát triển cơ bắp tối đa. Lý tưởng cho người muốn tăng khối cơ.',
    descriptionEN: 'Focuses on moderate weights and 8-12 reps for maximum muscle growth. Ideal for those looking to build lean muscle mass.',
    difficulty: 'medium',
    graduationXp: 8500,
    xpBase: 100,
    xpSlope: 1.45,
    iconEmoji: '💪',
    colorHex: 0xFF00E676, // Emerald green
  ),

  // ─── C: Sức Mạnh / Powerlifting ───
  'C': ClassDefinition(
    classId: 'C',
    classNameVI: 'Chiến Binh Lực',
    classNameEN: 'Powerlifting',
    focusVI: 'Tạ cực nặng, 1-5 rep, tập sức mạnh bộc phát',
    focusEN: 'Very heavy weights, 1-5 reps, explosive power training',
    descriptionVI: 'Rèn luyện sức mạnh bộc phát với mức tạ cực nặng. Tập trung vào 3 bài tập lớn: Squat, Bench Press, Deadlift.',
    descriptionEN: 'Train explosive power with very heavy loads. Focuses on the Big 3: Squat, Bench Press, Deadlift.',
    difficulty: 'hard',
    graduationXp: 11000,
    xpBase: 130,
    xpSlope: 1.55,
    iconEmoji: '🛡️',
    colorHex: 0xFFFF1744, // Crimson red
  ),

  // ─── D: Sức Bền / Endurance ───
  'D': ClassDefinition(
    classId: 'D',
    classNameVI: 'Thép Bền Bỉ',
    classNameEN: 'Endurance',
    focusVI: 'Rep cực cao (15+), nghỉ ngắn, sức chịu đựng',
    focusEN: 'Very high reps (15+), short rests, stamina focus',
    descriptionVI: 'Gia tăng sức chịu đựng của tim mạch và cơ bắp. Phù hợp với người tập chạy bộ, bơi lội hoặc muốn cải thiện thể lực lâu dài.',
    descriptionEN: 'Increase cardiovascular and muscular stamina. Suits runners, swimmers, or anyone seeking long-term endurance gains.',
    difficulty: 'easy',
    graduationXp: 7000,
    xpBase: 80,
    xpSlope: 1.40,
    iconEmoji: '⚡',
    colorHex: 0xFF00E5FF, // Electric cyan
  ),

  // ─── E: Calisthenics / Bodyweight ───
  'E': ClassDefinition(
    classId: 'E',
    classNameVI: 'Kháng Lực Sĩ',
    classNameEN: 'Calisthenics',
    focusVI: 'Kỹ thuật Bodyweight, Pull-up, Muscle-up',
    focusEN: 'Bodyweight mastery, Pull-ups, Muscle-ups',
    descriptionVI: 'Làm chủ cơ thể, vượt qua trọng lực. Tập trung vào các động tác kháng lực như Pull-up, Push-up, Muscle-up và Handstand.',
    descriptionEN: 'Master body control, defy gravity. Focuses on bodyweight movements like pull-ups, push-ups, muscle-ups, and handstands.',
    difficulty: 'medium',
    graduationXp: 9000,
    xpBase: 100,
    xpSlope: 1.45,
    iconEmoji: '🧘',
    colorHex: 0xFFE040FB, // Vibrant violet
  ),

  // ─── F: Bodybuilding / Kiến Tạo Hoàn Hảo ───
  'F': ClassDefinition(
    classId: 'F',
    classNameVI: 'Kiến Tạo Hoàn Mỹ',
    classNameEN: 'Bodybuilding',
    focusVI: 'Tỉ lệ cơ thể, đối xứng, kỷ luật khắt khe',
    focusEN: 'Body proportions, symmetry, strict discipline',
    descriptionVI: 'Chế độ vi chỉnh chuyên sâu từng nhóm cơ nhỏ. Yêu cầu sự kiên trì cao và kỷ luật khắt khe trong dinh dưỡng lẫn tập luyện.',
    descriptionEN: 'Intensive micro-adjustments for specific muscle groups. Demands extreme patience and discipline in both nutrition and training.',
    difficulty: 'hardcore',
    graduationXp: 15000,
    xpBase: 160,
    xpSlope: 1.65,
    iconEmoji: '👑',
    colorHex: 0xFFFFD600, // Royal gold
  ),
};

/// ═══════════════════════════════════════════════════════════════
/// Synergy pairs — defines which class combos unlock bonuses
/// ═══════════════════════════════════════════════════════════════
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
  // Giảm Cân + Sức Bền = hiệp lực hoàn hảo (Cardio-focused pairing)
  ClassSynergy(primaryClassId: 'A', secondaryClassId: 'D', synergyName: 'Cardio Storm', bonusPercent: 5, isPerfect: true),
  // Tăng Cơ + Sức Mạnh = hiệp lực hoàn hảo (Power-Hypertrophy combo)
  ClassSynergy(primaryClassId: 'B', secondaryClassId: 'C', synergyName: 'Juggernaut', bonusPercent: 5, isPerfect: true),
  // Calisthenics + Sức Mạnh = hiệp lực hoàn hảo (Bodyweight + Raw Power)
  ClassSynergy(primaryClassId: 'E', secondaryClassId: 'C', synergyName: 'Cyber Monk', bonusPercent: 5, isPerfect: true),
  // Bodybuilding + Tăng Cơ = hiệp lực hoàn hảo (Aesthetics + Volume)
  ClassSynergy(primaryClassId: 'F', secondaryClassId: 'B', synergyName: 'Apex Sculptor', bonusPercent: 5, isPerfect: true),
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
    case 'A': return ['D', 'B'];        // Giảm Cân → Sức Bền, Tăng Cơ
    case 'B': return ['C', 'F', 'A'];   // Tăng Cơ → Sức Mạnh, Bodybuilding, Giảm Cân
    case 'C': return ['B', 'E'];        // Sức Mạnh → Tăng Cơ, Calisthenics
    case 'D': return ['A', 'E'];        // Sức Bền → Giảm Cân, Calisthenics
    case 'E': return ['C', 'D'];        // Calisthenics → Sức Mạnh, Sức Bền
    case 'F': return ['B', 'C'];        // Bodybuilding → Tăng Cơ, Sức Mạnh
    default:  return [];
  }
}
