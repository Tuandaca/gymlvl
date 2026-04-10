// ... (existing interfaces)

export function getSuggestedWeight(profile: any, exercise: any): number {
  const bw = profile.weight_kg || 70;
  const isMale = profile.gender === 'male';
  let factor = 0.2; // Default baseline

  // Biometric Factor based on environment and goals
  // Focus on basic compounds for beginners
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

  // Adjust for experience
  if (profile.experience_level === 'intermediate') factor *= 1.3;
  if (profile.experience_level === 'advanced') factor *= 1.6;

  return Math.round(bw * factor * 2) / 2; // Round to nearest 0.5kg
}

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

  // 2. Standard Training XP (Aligned with Frontend)
  const durationMinutes = Math.floor((workout.duration_seconds || 0) / 60);
  const durationXP = Math.min(durationMinutes * 2, 120); // 2 XP/min, max 120

  let totalSets = 0;
  const categories = new Set();

  if (workout.workout_exercises) {
    for (const ex of workout.workout_exercises) {
      const completedSetsInExercise = (ex.workout_sets || []).filter((s: any) => s.is_completed).length;
      if (completedSetsInExercise > 0) {
        totalSets += completedSetsInExercise;
        if (ex.exercises?.category) {
          categories.add(ex.exercises.category);
        }
      }
    }
  }

  const volumeXP = totalSets * 3; // 3 XP per set
  const varietyXP = Math.max(0, categories.size - 1) * 5; // 5 XP per additional category

  const streakMultiplier = Math.min(1 + userStreak * 0.05, 1.5);

  const totalXP = Math.floor((durationXP + volumeXP + varietyXP) * streakMultiplier);
  
  return Math.min(totalXP, 500); // Global cap
}

// XP Required Curve
export function xpRequiredForLevel(level: number): number {
  return Math.floor(100 * Math.pow(level, 1.5));
}

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
 * Checks if a workout satisfies the requirements of a specific quest.
 */
export function verifyQuestCompletion(workout: any, questConfig: any): boolean {
  if (!questConfig || !questConfig.exercises) return false;
  
  // Logic: User must complete at least 80% of the prescribed exercises
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

  // 1. Basic checks
  if (totalSets === 0) errors.push("No completed sets found");
  if (durationSeconds <= 0) errors.push("Invalid duration");

  // 2. Suspicious Pace Check (e.g., more than 3 sets per minute is highly unlikely)
  const minutes = durationSeconds / 60;
  const pace = totalSets / (minutes > 0 ? minutes : 1);
  
  if (pace > 4 && totalSets > 3) {
    isSuspicious = true;
  }

  // 3. Time logic parity (Workout shouldn't be completed in the future)
  const now = new Date();
  const completedAt = workout.completed_at ? new Date(workout.completed_at) : now;
  if (completedAt > new Date(now.getTime() + 60000)) { // 1 min buffer for clock drift
    errors.push("Workout completion time is in the future");
  }

  return {
    valid: errors.length === 0,
    isSuspicious,
    errors: errors.length > 0 ? errors : undefined
  };
}
