export interface ValidationResult {
  valid: boolean;
  isSuspicious: boolean;
  errors: string[];
}

export function validateWorkout(workout: any): ValidationResult {
  const errors: string[] = [];
  let isSuspicious = false;
  
  const durationSeconds = workout.duration_seconds || 0;
  const durationMinutes = durationSeconds / 60;

  // 1. Check max duration (4 hours)
  if (durationSeconds > 14400) {
    errors.push("Workout too long (maximum 4 hours)");
  }

  // 2. Check exercises array existence
  if (!workout.workout_exercises || workout.workout_exercises.length === 0) {
    errors.push("No exercises in workout");
    return { valid: false, isSuspicious: false, errors };
  }

  let totalSets = 0;
  for (const ex of workout.workout_exercises) {
    if (ex.workout_sets) {
      const completedSets = ex.workout_sets.filter((s: any) => s.is_completed === true).length;
      totalSets += completedSets;

      // 3. Max 30 sets per exercise
      if (ex.workout_sets.length > 30) {
        errors.push(`Too many sets for exercise ID: ${ex.exercise_id}`);
      }
      
      // 4. Check for unrealistic weight (max 500kg)
      for (const set of ex.workout_sets) {
        if (set.weight_kg > 500) {
          errors.push(`Unrealistic weight: ${set.weight_kg}kg`);
        }
      }
    }
  }

  // 5. Check Pace (Suspicious if sets > 3 and pace > 3 sets/min)
  // Example: 15 sets in 2 minutes = 7.5 pace -> Suspicious
  if (totalSets > 3 && durationMinutes > 0) {
    const pace = totalSets / durationMinutes;
    if (pace > 3) {
      isSuspicious = true;
    }
  }

  return { 
    valid: errors.length === 0, 
    isSuspicious,
    errors 
  };
}

export function calculateXP(workout: any, userStreak: number = 0, isSuspicious: boolean = false): number {
  if (isSuspicious) {
    return 10; // Cap at 10 XP if suspicious
  }

  const durationMinutes = Math.floor((workout.duration_seconds || 0) / 60);
  const durationXP = Math.min(durationMinutes * 2, 120); 

  let totalSets = 0;
  const categories = new Set<string>();

  if (workout.workout_exercises) {
    for (const ex of workout.workout_exercises) {
      if (ex.workout_sets) {
        const completedSets = ex.workout_sets.filter((s: any) => s.is_completed === true).length;
        totalSets += completedSets;
      }
      if (ex.exercises && ex.exercises.category) {
        categories.add(ex.exercises.category);
      }
    }
  }

  const volumeXP = totalSets * 3;
  const varietyXP = categories.size * 5;
  const streakMultiplier = Math.min(1 + userStreak * 0.05, 2.0);

  const rawXP = (durationXP + volumeXP + varietyXP) * streakMultiplier;
  return Math.floor(Math.min(rawXP, 500)); // Daily / Workout cap
}

// XP tích lũy để đạt level N
export function xpRequiredForLevel(level: number): number {
  return Math.floor(100 * Math.pow(level, 1.5));
}

// Kiểm tra level-up dựa trên số totalXP
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
