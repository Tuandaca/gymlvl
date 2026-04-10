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

  // 1. Base Quest XP (The primary source)
  if (isQuest) {
    let questXP = 300; // Base reward for completing the assigned route
    if (matchesQuestTargets) {
      questXP += 100; // Bonus for hitting exactly the prescribed weights/reps
    }
    const streakMultiplier = Math.min(1 + userStreak * 0.05, 2.0);
    return Math.floor(questXP * streakMultiplier);
  }

  // 2. Standard Training XP (The secondary source)
  const durationMinutes = Math.floor((workout.duration_seconds || 0) / 60);
  const durationXP = Math.min(durationMinutes * 1, 60); // Lower reward for free training

  let totalSets = 0;
  if (workout.workout_exercises) {
    for (const ex of workout.workout_exercises) {
      if (ex.workout_sets) {
        totalSets += ex.workout_sets.filter((s: any) => s.is_completed).length;
      }
    }
  }

  const volumeXP = totalSets * 2;
  const streakMultiplier = Math.min(1 + userStreak * 0.05, 1.5); // Cap lower for free training

  return Math.floor((durationXP + volumeXP) * streakMultiplier);
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
