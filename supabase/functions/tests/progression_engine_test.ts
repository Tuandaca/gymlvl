import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { calculateXP, validateWorkout, xpRequiredForLevel } from "../_shared/progression_engine.ts";

Deno.test("Progression Engine - XP Calculation", () => {
  // 1. Normal workout
  const workout = {
    duration_seconds: 1800,
    workout_exercises: [
      { exercises: { category: "Chest" }, workout_sets: [{ is_completed: true }, { is_completed: true }] },
      { exercises: { category: "Back" }, workout_sets: [{ is_completed: true }] },
    ]
  };
  // durationXP = 30 * 2 = 60
  // volumeXP = 3 * 3 = 9
  // varietyXP = 2 * 5 = 10
  // total = 60 + 9 + 10 = 79
  assertEquals(calculateXP(workout, 0), 79);

  // 2. Suspicious Capping
  assertEquals(calculateXP(workout, 0, true), 10);
});

Deno.test("Progression Engine - Anti-Cheat Validation", () => {
  // 1. Valid workout
  const validWorkout = {
    duration_seconds: 1800,
    workout_exercises: [
      { exercise_id: "1", workout_sets: [{ is_completed: true, weight_kg: 50 }] }
    ]
  };
  assertEquals(validateWorkout(validWorkout).valid, true);
  assertEquals(validateWorkout(validWorkout).isSuspicious, false);

  // 2. Suspicious Pace
  const suspiciousWorkout = {
    duration_seconds: 60, // 1 minute
    workout_exercises: [
      { exercise_id: "1", workout_sets: Array(10).fill({ is_completed: true, weight_kg: 50 }) }
    ]
  };
  // 10 sets / 1 min = 10 pace (> 3)
  assertEquals(validateWorkout(suspiciousWorkout).isSuspicious, true);

  // 3. Invalid: Too many sets
  const invalidSetsWorkout = {
    duration_seconds: 1800,
    workout_exercises: [
      { exercise_id: "1", workout_sets: Array(31).fill({ is_completed: true, weight_kg: 50 }) }
    ]
  };
  assertEquals(validateWorkout(invalidSetsWorkout).valid, false);

  // 4. Invalid: Unrealistic weight
  const heavyWorkout = {
    duration_seconds: 1800,
    workout_exercises: [
      { exercise_id: "1", workout_sets: [{ is_completed: true, weight_kg: 600 }] }
    ]
  };
  assertEquals(validateWorkout(heavyWorkout).valid, false);
});

Deno.test("Progression Engine - Level Curve", () => {
  assertEquals(xpRequiredForLevel(1), 100);
  assertEquals(xpRequiredForLevel(10), 3162);
});
