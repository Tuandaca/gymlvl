// ==============================================================================
// PROGRESSION ENGINE v2 — Multi-Class XP System
// ==============================================================================
// Reference: docs/CLASS_SYSTEM_SPEC.md
// Handles: XP calculation, Class-specific leveling, Synergy bonuses, Graduation

// --- Class XP Curve Definitions ---
interface ClassXPConfig {
  base: number;
  slope: number;
}

const CLASS_XP_CURVES: Record<string, ClassXPConfig> = {
  easy:     { base: 80,  slope: 1.40 },
  medium:   { base: 100, slope: 1.45 },
  hard:     { base: 130, slope: 1.55 },
  hardcore: { base: 160, slope: 1.65 },
};

// --- Class Focus Mapping ---
// Maps class_id to the exercise categories that count as "Focus Match"
const CLASS_FOCUS_CATEGORIES: Record<string, string[]> = {
  'A': ['cardio', 'hiit', 'full_body'],                    // Fat Slayer
  'B': ['chest', 'back', 'legs', 'shoulders', 'full_body'], // Recomp Ghost
  'C': ['chest', 'back', 'legs', 'shoulders', 'arms'],      // Mass Architect
  'D': ['legs', 'back', 'chest'],                           // Titan Strength (compound lifts)
  'E': ['full_body', 'plyometrics', 'cardio'],              // Nitro Athlete
  'F': ['cardio', 'full_body', 'endurance'],                // Enduro Guard
  'G': ['calisthenics', 'core', 'full_body'],               // Gravity Defier
  'H': ['chest', 'back', 'legs', 'shoulders', 'arms'],      // Apex Competitor
};

// --- Perfect Synergy Pairs ---
const PERFECT_SYNERGIES: [string, string][] = [
  ['A', 'B'], // The Shredder
  ['C', 'D'], // Juggernaut
  ['G', 'D'], // Cyber Monk
  ['E', 'F'], // First Responder
];

// ==============================================================================
// PUBLIC API
// ==============================================================================

export function getSuggestedWeight(profile: any, exercise: any): number {
  const bw = profile.weight_kg || 70;
  const isMale = profile.gender === 'male';
  let factor = 0.2;

  const category = (exercise.category || '').toLowerCase();
  
  if (category.includes('chest') || category.includes('push')) {
    factor = isMale ? 0.4 : 0.25;
  } else if (category.includes('leg') || category.includes('squat')) {
    factor = isMale ? 0.6 : 0.4;
  } else if (category.includes('back') || category.includes('deadlift')) {
    factor = isMale ? 0.7 : 0.5;
  } else if (category.includes('arm') || category.includes('shoulder')) {
    factor = isMale ? 0.15 : 0.08;
  }

  if (profile.experience_level === 'intermediate') factor *= 1.3;
  if (profile.experience_level === 'advanced') factor *= 1.6;

  return Math.round(bw * factor * 2) / 2;
}

/**
 * Calculate XP earned from a workout.
 * XP is based on: completed sets + exercise variety + streak bonus.
 * Duration is NOT counted to avoid phantom XP before completing any sets.
 */
export function calculateXP(workout: any, options: { 
  userStreak: number, 
  isSuspicious: boolean, 
  isQuest?: boolean,
  matchesQuestTargets?: boolean 
}): number {
  const { userStreak = 0, isSuspicious = false, isQuest = false, matchesQuestTargets = false } = options;

  if (isSuspicious) return 10;

  // 1. Base Quest XP (Special high reward route)
  if (isQuest) {
    let questXP = 300; 
    if (matchesQuestTargets) questXP += 100;
    const streakMultiplier = Math.min(1 + userStreak * 0.05, 2.0);
    return Math.floor(questXP * streakMultiplier);
  }

  // 2. Standard Training XP — NO duration XP
  let volumeXP = 0;
  const categories = new Set();

  if (workout.workout_exercises) {
    for (const ex of workout.workout_exercises) {
      if (!ex.workout_sets) continue;
      
      const completedSets = ex.workout_sets.filter((s: any) => s.is_completed);
      
      if (completedSets.length > 0) {
        if (ex.exercises?.category) {
          categories.add(ex.exercises.category);
        }
        
        // Caculate volume XP dynamically for each set
        for (const set of completedSets) {
          const actualWeight = parseFloat(set.weight_kg) || 0;
          const baselineWeight = parseFloat(set.baseline_weight_kg) || 0;
          
          let setXP = 5; // Base XP for a set
          
          if (baselineWeight > 0) {
            // Dynamic Overload Scaling (Effort Ratio)
            const effortRatio = actualWeight / baselineWeight;
            // Cap the ratio between 0.2 (extremely light) and 3.0 (massive PR) to prevent exploit
            const safeRatio = Math.min(Math.max(effortRatio, 0.2), 3.0);
            setXP = 5 * safeRatio;
          } else if (actualWeight > 0) {
              // If there was no baseline but they lifted weight, give standard XP
              setXP = 5;
          }
          
          volumeXP += setXP;
        }
      }
    }
  }

  if (volumeXP === 0) return 0;

  // Variety XP: 8 XP per unique category (starting from 2nd)
  const varietyXP = Math.max(0, categories.size - 1) * 8;
  const streakMultiplier = Math.min(1 + userStreak * 0.05, 1.5);
  const totalXP = Math.floor((volumeXP + varietyXP) * streakMultiplier);
  
  return Math.min(totalXP, 1000); // Increased cap to 1000 since dynamic overload can yield large XP
}

/**
 * Allocate XP to individual classes based on workout exercise categories.
 * 
 * Rules (from CLASS_SYSTEM_SPEC.md §6):
 * - Focus Match: Exercise category matches class focus → 100% XP
 * - Focus Mismatch: Exercise doesn't match → 40% XP (background XP)
 * - Double Focus: Matches both classes → both get 100%
 * - Synergy Bonus: +5% if the pair is a Perfect Synergy combo
 */
export function allocateClassXP(
  baseXP: number,
  workout: any,
  userClasses: any[] // Array of user_classes records
): { classId: string; xpEarned: number; newTotalXP: number; slot: string }[] {
  if (!userClasses || userClasses.length === 0) return [];

  const results: { classId: string; xpEarned: number; newTotalXP: number; slot: string }[] = [];
  
  // Collect exercise categories from the workout
  const workoutCategories = new Set<string>();
  if (workout.workout_exercises) {
    for (const ex of workout.workout_exercises) {
      const completedSets = (ex.workout_sets || []).filter((s: any) => s.is_completed).length;
      if (completedSets > 0 && ex.exercises?.category) {
        workoutCategories.add(ex.exercises.category.toLowerCase());
      }
    }
  }

  // Check if pair is a perfect synergy
  const hasSynergy = userClasses.length === 2 && isPerfectSynergy(
    userClasses[0].class_id, 
    userClasses[1].class_id
  );
  const synergyMultiplier = hasSynergy ? 1.05 : 1.0;

  for (const uc of userClasses) {
    const classFocus = CLASS_FOCUS_CATEGORIES[uc.class_id] || [];
    
    // Check if any workout exercise matches the class focus
    let hasFocusMatch = false;
    for (const cat of Array.from(workoutCategories)) {
      if (classFocus.includes(cat)) {
        hasFocusMatch = true;
        break;
      }
    }

    // Apply Focus Match / Mismatch ratio
    const focusRatio = hasFocusMatch ? 1.0 : 0.4;
    const classXP = Math.floor(baseXP * focusRatio * synergyMultiplier);
    
    results.push({
      classId: uc.class_id,
      xpEarned: classXP,
      newTotalXP: (uc.current_xp || 0) + classXP,
      slot: uc.slot,
    });
  }

  return results;
}

/**
 * Check if two classes form a Perfect Synergy pair (order doesn't matter).
 */
export function isPerfectSynergy(classA: string, classB: string): boolean {
  return PERFECT_SYNERGIES.some(
    ([a, b]) => (a === classA && b === classB) || (a === classB && b === classA)
  );
}

/**
 * XP required to reach a specific level for a given difficulty class.
 * Formula: Total_XP = base * (level ^ slope)
 */
export function xpRequiredForClassLevel(level: number, difficulty: string): number {
  const config = CLASS_XP_CURVES[difficulty] || CLASS_XP_CURVES['medium'];
  return Math.floor(config.base * Math.pow(level, config.slope));
}

/**
 * Legacy: Global XP Required (used for the `users` table level).
 */
export function xpRequiredForLevel(level: number): number {
  return Math.floor(100 * Math.pow(level, 1.5));
}

/**
 * Check and compute the new level for the global user level (users table).
 */
export function checkLevel(currentLevel: number, totalXP: number): { newLevel: number, leveledUp: boolean, nextLevelXp: number } {
  let tempLevel = currentLevel;
  while (totalXP >= xpRequiredForLevel(tempLevel)) {
    tempLevel++;
  }
  return {
    newLevel: tempLevel,
    leveledUp: tempLevel > currentLevel,
    nextLevelXp: xpRequiredForLevel(tempLevel),
  };
}

/**
 * Check and compute the new level for a specific class.
 */
export function checkClassLevel(
  currentLevel: number, 
  totalXP: number, 
  difficulty: string
): { newLevel: number; leveledUp: boolean; isGraduation: boolean; nextLevelXp: number } {
  let tempLevel = currentLevel;
  while (totalXP >= xpRequiredForClassLevel(tempLevel, difficulty)) {
    tempLevel++;
  }
  return {
    newLevel: tempLevel,
    leveledUp: tempLevel > currentLevel,
    isGraduation: tempLevel >= 20 && currentLevel < 20,
    nextLevelXp: xpRequiredForClassLevel(tempLevel, difficulty),
  };
}

/**
 * Checks if a workout satisfies the requirements of a specific quest.
 */
export function verifyQuestCompletion(workout: any, questConfig: any): boolean {
  if (!questConfig || !questConfig.exercises) return false;
  
  const completedExercises = workout.workout_exercises || [];
  let matchingCount = 0;

  for (const target of questConfig.exercises) {
    const found = completedExercises.find((ce: any) => ce.exercise_id === target.exercise_id);
    if (found) {
      const completedSets = (found.workout_sets || []).filter((s: any) => s.is_completed).length;
      if (completedSets >= target.sets) {
        matchingCount++;
      }
    }
  }

  return (matchingCount / questConfig.exercises.length) >= 0.8;
}

/**
 * Validates a workout for anti-cheat and basic integrity.
 */
export function validateWorkout(workout: any): { valid: boolean; isSuspicious: boolean; errors?: string[] } {
  const errors: string[] = [];
  let isSuspicious = false;

  const durationSeconds = workout.duration_seconds || 0;
  
  let totalSets = 0;
  if (workout.workout_exercises) {
    for (const ex of workout.workout_exercises) {
      if (ex.workout_sets) {
        totalSets += ex.workout_sets.filter((s: any) => s.is_completed).length;
      }
    }
  }

  if (totalSets === 0) errors.push("No completed sets found");
  if (durationSeconds <= 0) errors.push("Invalid duration");

  const minutes = durationSeconds / 60;
  const pace = totalSets / (minutes > 0 ? minutes : 1);
  
  if (pace > 4 && totalSets > 3) {
    isSuspicious = true;
  }

  const now = new Date();
  const completedAt = workout.completed_at ? new Date(workout.completed_at) : now;
  if (completedAt > new Date(now.getTime() + 60000)) {
    errors.push("Workout completion time is in the future");
  }

  return {
    valid: errors.length === 0,
    isSuspicious,
    errors: errors.length > 0 ? errors : undefined
  };
}
