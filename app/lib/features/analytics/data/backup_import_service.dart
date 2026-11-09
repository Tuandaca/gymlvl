/// P7 Gate 4: Backup restore / GymLvl portable import.
///
/// Restores a previously exported GymLvl backup (format "gymlvl-backup",
/// version 1). Strict validation, preview before confirmation, deterministic
/// idempotent restore, and zero retroactive rewards for historical workouts.
///
/// Uses the P4 BackupExportService schema as authority. Never restores
/// passwords, tokens, secrets, or arbitrary RPG state.
library;

import 'dart:convert';

import 'package:app/features/workout/domain/exercise_repository.dart';
import 'package:app/features/workout/domain/workout_repository.dart';

const String kBackupFormat = 'gymlvl-backup';
const int kBackupVersion = 1;

/// Status of a record during backup restore preview/restore.
enum RestoreRecordStatus { newRecord, existing, duplicate, conflict, invalid }

/// Result of validating a backup before restore.
class BackupRestoreValidationResult {
  const BackupRestoreValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool isValid;
  final List<RestoreValidationError> errors;
  final List<RestoreValidationWarning> warnings;
}

/// A validation error that blocks restore.
class RestoreValidationError {
  const RestoreValidationError({
    required this.code,
    required this.message,
    this.section,
  });

  final String code;
  final String message;
  final String? section;
}

/// A validation warning that does not block restore.
class RestoreValidationWarning {
  const RestoreValidationWarning({
    required this.code,
    required this.message,
    this.section,
  });

  final String code;
  final String message;
  final String? section;
}

/// Preview of a backup restore, showing what would be restored and any
/// conflicts or duplicates.
class BackupRestorePreview {
  const BackupRestorePreview({
    required this.validationResult,
    required this.workoutCount,
    required this.workoutExerciseCount,
    required this.workoutSetCount,
    required this.measurementCount,
    required this.customExerciseCount,
    required this.recordStatuses,
    this.hasDuplicates = false,
    this.hasConflicts = false,
  });

  final BackupRestoreValidationResult validationResult;
  final int workoutCount;
  final int workoutExerciseCount;
  final int workoutSetCount;
  final int measurementCount;
  final int customExerciseCount;
  final List<RestoreRecordPreview> recordStatuses;
  final bool hasDuplicates;
  final bool hasConflicts;

  bool get canRestore => validationResult.isValid && !hasConflicts;
}

/// Preview status for a single record being restored.
class RestoreRecordPreview {
  const RestoreRecordPreview({
    required this.recordType,
    required this.sourceId,
    required this.status,
    this.message,
  });

  final String
  recordType; // 'workout', 'workout_exercise', 'workout_set', 'body_measurement', 'custom_exercise'
  final String sourceId;
  final RestoreRecordStatus status;
  final String? message;
}

/// Result of confirming and executing a backup restore.
class BackupRestoreResult {
  const BackupRestoreResult({
    required this.success,
    this.restoredWorkoutCount = 0,
    this.restoredExerciseCount = 0,
    this.restoredSetCount = 0,
    this.restoredMeasurementCount = 0,
    this.restoredCustomExerciseCount = 0,
    this.skippedDuplicateCount = 0,
    this.warnings = const [],
    this.errors = const [],
  });

  final bool success;
  final int restoredWorkoutCount;
  final int restoredExerciseCount;
  final int restoredSetCount;
  final int restoredMeasurementCount;
  final int restoredCustomExerciseCount;
  final int skippedDuplicateCount;
  final List<RestoreValidationWarning> warnings;
  final List<RestoreValidationError> errors;
}

/// Service for validating, previewing, and restoring GymLvl backups.
class BackupImportService {
  final WorkoutRepository workoutRepository;
  final ExerciseRepository exerciseRepository;

  BackupImportService({
    required this.workoutRepository,
    required this.exerciseRepository,
  });

  /// Validate and preview a backup JSON string without persisting anything.
  BackupRestorePreview preview(String jsonContent) {
    final errors = <RestoreValidationError>[];
    final warnings = <RestoreValidationWarning>[];

    // 1. Parse JSON
    Map<String, dynamic> parsed;
    try {
      parsed = json.decode(jsonContent) as Map<String, dynamic>;
    } catch (e) {
      errors.add(
        const RestoreValidationError(
          code: 'invalid_json',
          message: 'Không thể phân tích cú pháp JSON: file bị hỏng.',
        ),
      );
      return BackupRestorePreview(
        validationResult: BackupRestoreValidationResult(
          isValid: false,
          errors: errors,
          warnings: warnings,
        ),
        workoutCount: 0,
        workoutExerciseCount: 0,
        workoutSetCount: 0,
        measurementCount: 0,
        customExerciseCount: 0,
        recordStatuses: const [],
        hasDuplicates: false,
        hasConflicts: false,
      );
    }

    // 2. Validate format
    final format = parsed['format'];
    if (format != kBackupFormat) {
      errors.add(
        RestoreValidationError(
          code: 'unsupported_format',
          message: 'Định định dạng bản sao lưu không được hỗ trợ: $format.',
          section: 'format',
        ),
      );
    }

    // 3. Validate version
    final version = parsed['version'];
    if (version == null || version is! int || version != kBackupVersion) {
      errors.add(
        RestoreValidationError(
          code: 'unsupported_version',
          message:
              'Phiên bản không được hỗ trợ: $version. Yêu cầu phiên bản $kBackupVersion.',
          section: 'version',
        ),
      );
    }

    // 4. Validate data section exists
    final data = parsed['data'];
    if (data == null || data is! Map<String, dynamic>) {
      errors.add(
        const RestoreValidationError(
          code: 'missing_data_section',
          message: 'Thiếu phần dữ liệu trong bản sao lưu.',
          section: 'data',
        ),
      );
      return BackupRestorePreview(
        validationResult: BackupRestoreValidationResult(
          isValid: false,
          errors: errors,
          warnings: warnings,
        ),
        workoutCount: 0,
        workoutExerciseCount: 0,
        workoutSetCount: 0,
        measurementCount: 0,
        customExerciseCount: 0,
        recordStatuses: const [],
        hasDuplicates: false,
        hasConflicts: false,
      );
    }

    // 5. Validate user_id
    final userId = data['user_id'];
    if (userId == null || userId is! String || userId.isEmpty) {
      errors.add(
        const RestoreValidationError(
          code: 'invalid_user_id',
          message: 'user_id không hợp lệ trong bản sao lưu.',
          section: 'data.user_id',
        ),
      );
    }

    if (errors.isNotEmpty) {
      return BackupRestorePreview(
        validationResult: BackupRestoreValidationResult(
          isValid: false,
          errors: errors,
          warnings: warnings,
        ),
        workoutCount: 0,
        workoutExerciseCount: 0,
        workoutSetCount: 0,
        measurementCount: 0,
        customExerciseCount: 0,
        recordStatuses: const [],
        hasDuplicates: false,
        hasConflicts: false,
      );
    }

    final dataMap = data as Map<String, dynamic>;

    // 6. Validate workouts
    final workoutsRaw = dataMap['workouts'];
    if (workoutsRaw == null || workoutsRaw is! List) {
      errors.add(
        const RestoreValidationError(
          code: 'missing_workouts',
          message: 'Thiếu danh sách workouts trong dữ liệu.',
          section: 'data.workouts',
        ),
      );
      return BackupRestorePreview(
        validationResult: BackupRestoreValidationResult(
          isValid: false,
          errors: errors,
          warnings: warnings,
        ),
        workoutCount: 0,
        workoutExerciseCount: 0,
        workoutSetCount: 0,
        measurementCount: 0,
        customExerciseCount: 0,
        recordStatuses: const [],
        hasDuplicates: false,
        hasConflicts: false,
      );
    }

    final workouts = <Map<String, dynamic>>[];
    final workoutIds = <String>{};
    var hasDuplicateWorkouts = false;

    for (var i = 0; i < workoutsRaw.length; i++) {
      final w = workoutsRaw[i];
      if (w is! Map<String, dynamic>) {
        errors.add(
          RestoreValidationError(
            code: 'invalid_workout_record',
            message: 'Bản ghi workout không hợp lệ tại chỉ số $i.',
            section: 'data.workouts[$i]',
          ),
        );
        continue;
      }

      final wId = w['workout_id'];
      if (wId == null || wId is! String || wId.isEmpty) {
        errors.add(
          RestoreValidationError(
            code: 'invalid_workout_id',
            message: 'workout_id không hợp lệ tại chỉ số $i.',
            section: 'data.workouts[$i].workout_id',
          ),
        );
        continue;
      }

      if (workoutIds.contains(wId)) {
        hasDuplicateWorkouts = true;
        errors.add(
          RestoreValidationError(
            code: 'duplicate_workout_id',
            message: 'workout_id trùng lặp: $wId.',
            section: 'data.workouts[$i].workout_id',
          ),
        );
      } else {
        workoutIds.add(wId);
      }

      // Validate dates if present
      final startedAt = _parseDateTime(w['started_at']);
      final completedAt = _parseDateTime(w['completed_at']);
      final createdAt = _parseDateTime(w['created_at']);
      final updatedAt = _parseDateTime(w['updated_at']);

      if (w['started_at'] != null && startedAt == null) {
        errors.add(
          RestoreValidationError(
            code: 'invalid_date',
            message: 'Ngày bắt đầu không hợp lệ: ${w['started_at']}.',
            section: 'data.workouts[$i].started_at',
          ),
        );
      }

      // Validate numeric fields
      if (w['duration_seconds'] != null && w['duration_seconds'] is! num) {
        errors.add(
          RestoreValidationError(
            code: 'invalid_number',
            message: 'duration_seconds phải là số.',
            section: 'data.workouts[$i].duration_seconds',
          ),
        );
      }

      workouts.add(w);
    }

    // 7. Validate workout_exercises
    final weRaw = dataMap['workout_exercises'];
    final weList = <Map<String, dynamic>>[];
    final weIds = <String>{};
    var hasDuplicateWe = false;

    if (weRaw != null) {
      if (weRaw is! List) {
        errors.add(
          const RestoreValidationError(
            code: 'invalid_workout_exercises',
            message: 'workout_exercises phải là danh sách.',
            section: 'data.workout_exercises',
          ),
        );
      } else {
        for (var i = 0; i < weRaw.length; i++) {
          final we = weRaw[i];
          if (we is! Map<String, dynamic>) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_workout_exercise_record',
                message: 'Bản ghi workout_exercise không hợp lệ tại chỉ số $i.',
                section: 'data.workout_exercises[$i]',
              ),
            );
            continue;
          }

          final weId = we['workout_exercise_id'];
          if (weId == null || weId is! String || weId.isEmpty) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_workout_exercise_id',
                message: 'workout_exercise_id không hợp lệ tại chỉ số $i.',
                section: 'data.workout_exercises[$i].workout_exercise_id',
              ),
            );
            continue;
          }

          if (weIds.contains(weId)) {
            hasDuplicateWe = true;
            errors.add(
              RestoreValidationError(
                code: 'duplicate_workout_exercise_id',
                message: 'workout_exercise_id trùng lặp: $weId.',
                section: 'data.workout_exercises[$i].workout_exercise_id',
              ),
            );
          } else {
            weIds.add(weId);
          }

          // Validate workout_id reference
          final wid = we['workout_id'];
          if (wid == null || wid is! String || wid.isEmpty) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_workout_reference',
                message:
                    'workout_id không hợp lệ trong workout_exercise tại chỉ số $i.',
                section: 'data.workout_exercises[$i].workout_id',
              ),
            );
          }

          // Validate exercise_id reference
          final eid = we['exercise_id'];
          if (eid == null || eid is! String || eid.isEmpty) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_exercise_reference',
                message:
                    'exercise_id không hợp lệ trong workout_exercise tại chỉ số $i.',
                section: 'data.workout_exercises[$i].exercise_id',
              ),
            );
          }

          weList.add(we);
        }
      }
    }

    // 8. Validate workout_sets
    final setsRaw = dataMap['workout_sets'];
    final setsList = <Map<String, dynamic>>[];
    final setIds = <String>{};
    var hasDuplicateSets = false;

    if (setsRaw != null) {
      if (setsRaw is! List) {
        errors.add(
          const RestoreValidationError(
            code: 'invalid_workout_sets',
            message: 'workout_sets phải là danh sách.',
            section: 'data.workout_sets',
          ),
        );
      } else {
        for (var i = 0; i < setsRaw.length; i++) {
          final s = setsRaw[i];
          if (s is! Map<String, dynamic>) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_workout_set_record',
                message: 'Bản ghi workout_set không hợp lệ tại chỉ số $i.',
                section: 'data.workout_sets[$i]',
              ),
            );
            continue;
          }

          final sId = s['set_id'];
          if (sId == null || sId is! String || sId.isEmpty) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_set_id',
                message: 'set_id không hợp lệ tại chỉ số $i.',
                section: 'data.workout_sets[$i].set_id',
              ),
            );
            continue;
          }

          if (setIds.contains(sId)) {
            hasDuplicateSets = true;
            errors.add(
              RestoreValidationError(
                code: 'duplicate_set_id',
                message: 'set_id trùng lặp: $sId.',
                section: 'data.workout_sets[$i].set_id',
              ),
            );
          } else {
            setIds.add(sId);
          }

          // Validate workout_exercise_id reference
          final weId = s['workout_exercise_id'];
          if (weId == null || weId is! String || weId.isEmpty) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_workout_exercise_reference',
                message:
                    'workout_exercise_id không hợp lệ trong workout_set tại chỉ số $i.',
                section: 'data.workout_sets[$i].workout_exercise_id',
              ),
            );
          }

          // Validate numeric fields
          if (s['reps'] != null && s['reps'] is! num) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_number',
                message: 'reps phải là số.',
                section: 'data.workout_sets[$i].reps',
              ),
            );
          }
          if (s['weight_kg'] != null && s['weight_kg'] is! num) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_number',
                message: 'weight_kg phải là số.',
                section: 'data.workout_sets[$i].weight_kg',
              ),
            );
          }
          if (s['duration_seconds'] != null && s['duration_seconds'] is! num) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_number',
                message: 'duration_seconds phải là số.',
                section: 'data.workout_sets[$i].duration_seconds',
              ),
            );
          }

          setsList.add(s);
        }
      }
    }

    // 9. Validate body_measurements
    final measurementsRaw = dataMap['body_measurements'];
    final measurementsList = <Map<String, dynamic>>[];
    final measurementIds = <String>{};
    var hasDuplicateMeasurements = false;

    if (measurementsRaw != null) {
      if (measurementsRaw is! List) {
        errors.add(
          const RestoreValidationError(
            code: 'invalid_body_measurements',
            message: 'body_measurements phải là danh sách.',
            section: 'data.body_measurements',
          ),
        );
      } else {
        for (var i = 0; i < measurementsRaw.length; i++) {
          final m = measurementsRaw[i];
          if (m is! Map<String, dynamic>) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_body_measurement_record',
                message: 'Bản ghi body_measurement không hợp lệ tại chỉ số $i.',
                section: 'data.body_measurements[$i]',
              ),
            );
            continue;
          }

          final mId = m['measurement_id'];
          if (mId == null || mId is! String || mId.isEmpty) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_measurement_id',
                message: 'measurement_id không hợp lệ tại chỉ số $i.',
                section: 'data.body_measurements[$i].measurement_id',
              ),
            );
            continue;
          }

          if (measurementIds.contains(mId)) {
            hasDuplicateMeasurements = true;
            errors.add(
              RestoreValidationError(
                code: 'duplicate_measurement_id',
                message: 'measurement_id trùng lặp: $mId.',
                section: 'data.body_measurements[$i].measurement_id',
              ),
            );
          } else {
            measurementIds.add(mId);
          }

          measurementsList.add(m);
        }
      }
    }

    final hasDuplicates =
        hasDuplicateWorkouts ||
        hasDuplicateWe ||
        hasDuplicateSets ||
        hasDuplicateMeasurements;
    final hasConflicts = errors.isNotEmpty;

    return BackupRestorePreview(
      validationResult: BackupRestoreValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      ),
      workoutCount: workouts.length,
      workoutExerciseCount: weList.length,
      workoutSetCount: setsList.length,
      measurementCount: measurementsList.length,
      customExerciseCount:
          0, // Backup does not export custom exercises separately
      recordStatuses: [
        ...workouts.map(
          (w) => RestoreRecordPreview(
            recordType: 'workout',
            sourceId: w['workout_id'] as String,
            status: hasDuplicateWorkouts
                ? RestoreRecordStatus.duplicate
                : RestoreRecordStatus.newRecord,
          ),
        ),
        ...weList.map(
          (we) => RestoreRecordPreview(
            recordType: 'workout_exercise',
            sourceId: we['workout_exercise_id'] as String,
            status: hasDuplicateWe
                ? RestoreRecordStatus.duplicate
                : RestoreRecordStatus.newRecord,
          ),
        ),
        ...setsList.map(
          (s) => RestoreRecordPreview(
            recordType: 'workout_set',
            sourceId: s['set_id'] as String,
            status: hasDuplicateSets
                ? RestoreRecordStatus.duplicate
                : RestoreRecordStatus.newRecord,
          ),
        ),
        ...measurementsList.map(
          (m) => RestoreRecordPreview(
            recordType: 'body_measurement',
            sourceId: m['measurement_id'] as String,
            status: hasDuplicateMeasurements
                ? RestoreRecordStatus.duplicate
                : RestoreRecordStatus.newRecord,
          ),
        ),
      ],
      hasDuplicates: hasDuplicates,
      hasConflicts: hasConflicts,
    );
  }

  /// Confirm and execute the backup restore. Uses import-safe persistence
  /// (markWorkoutCompleted, NOT completeWorkout) so historical workouts
  /// grant ZERO XP and no RPG rewards.
  Future<BackupRestoreResult> restore({
    required String jsonContent,
    required String currentUserId,
    Future<bool> Function(String backupFingerprint)? isDuplicate,
    Future<void> Function(String backupFingerprint)? recordImported,
  }) async {
    final previewResult = preview(jsonContent);
    if (!previewResult.canRestore) {
      return BackupRestoreResult(
        success: false,
        errors: previewResult.validationResult.errors,
      );
    }

    // Deterministic content fingerprint — same backup content → same hash.
    final backupFingerprint = _sha1(jsonContent);

    // Check if this exact backup has already been imported for this owner.
    if (isDuplicate != null && await isDuplicate(backupFingerprint)) {
      return BackupRestoreResult(
        success: true,
        restoredWorkoutCount: 0,
        restoredExerciseCount: 0,
        restoredSetCount: 0,
        restoredMeasurementCount: 0,
        skippedDuplicateCount: 1,
        warnings: [
          const RestoreValidationWarning(
            code: 'already_imported',
            message:
                'Bản sao lưu này đã được khôi phục trước đó. Bỏ qua để tránh trùng dữ liệu.',
          ),
        ],
        errors: [],
      );
    }

    final parsed = json.decode(jsonContent) as Map<String, dynamic>;
    final data = parsed['data'] as Map<String, dynamic>;

    var restoredWorkouts = 0;
    var restoredExercises = 0;
    var restoredSets = 0;
    var restoredMeasurements = 0;
    var skippedDuplicates = 0;
    final warnings = <RestoreValidationWarning>[];
    final errors = <RestoreValidationError>[];

    final workoutsRaw = data['workouts'] as List;
    final weRaw = data['workout_exercises'] as List?;
    final setsRaw = data['workout_sets'] as List?;
    final measurementsRaw = data['body_measurements'] as List?;

    // Build lookup maps for referential integrity
    final weByWorkoutId = <String, List<Map<String, dynamic>>>{};
    if (weRaw != null) {
      for (final we in weRaw) {
        if (we is! Map<String, dynamic>) continue;
        final wid = we['workout_id'] as String?;
        if (wid != null) {
          (weByWorkoutId[wid] ??= []).add(we);
        }
      }
    }

    final setsByWeId = <String, List<Map<String, dynamic>>>{};
    if (setsRaw != null) {
      for (final s in setsRaw) {
        if (s is! Map<String, dynamic>) continue;
        final weId = s['workout_exercise_id'] as String?;
        if (weId != null) {
          (setsByWeId[weId] ??= []).add(s);
        }
      }
    }

    // Restore in dependency order: workouts -> workout_exercises -> sets -> measurements
    for (final wRaw in workoutsRaw) {
      if (wRaw is! Map<String, dynamic>) continue;

      try {
        final wId = wRaw['workout_id'] as String;
        final startedAt = _parseDateTime(wRaw['started_at']) ?? DateTime.now();
        final completedAt = _parseDateTime(wRaw['completed_at']);
        final durationSeconds = _parseInt(wRaw['duration_seconds']);
        final notes = wRaw['notes'] as String?;

        // Use startWorkout then add exercises/sets, then markWorkoutCompleted
        // (NOT completeWorkout) to avoid retroactive rewards.
        final workout = await workoutRepository.startWorkout();

        // Note: We cannot set the original workout_id as it's auto-generated.
        // The imported workout gets a new ID; referential integrity is
        // preserved through the new workout's exercise links.
        restoredWorkouts++;

        // Restore exercises for this workout
        final wes = (weByWorkoutId[wId] ?? <Map<String, dynamic>>[])
          ..sort(
            (a, b) => _parseInt(
              a['order_index'] ?? 0,
            ).compareTo(_parseInt(b['order_index'] ?? 0)),
          );

        var orderIndex = 0;
        for (final we in wes) {
          try {
            final wex = await workoutRepository.addExerciseToWorkout(
              workout.id,
              we['exercise_id'] as String,
              orderIndex++,
            );
            restoredExercises++;

            // Restore sets for this exercise
            final weSets =
                (setsByWeId[we['workout_exercise_id'] as String] ??
                      <Map<String, dynamic>>[])
                  ..sort(
                    (a, b) => _parseInt(
                      a['set_number'] ?? 1,
                    ).compareTo(_parseInt(b['set_number'] ?? 1)),
                  );

            var setNumber = 1;
            for (final s in weSets) {
              try {
                await workoutRepository.addSet(
                  wex.id,
                  setNumber++,
                  _parseInt(s['reps'] ?? 0),
                  (_parseDouble(s['weight_kg'] ?? 0)),
                  durationSeconds: _parseInt(s['duration_seconds'] ?? 0),
                );
                restoredSets++;
              } catch (e) {
                warnings.add(
                  RestoreValidationWarning(
                    code: 'set_restore_failed',
                    message: 'Khôi phục set thất bại: ${s['set_id']}.',
                  ),
                );
              }
            }
          } catch (e) {
            warnings.add(
              RestoreValidationWarning(
                code: 'exercise_restore_failed',
                message:
                    'Khôi phục bài tập thất bại: ${we['workout_exercise_id']}.',
              ),
            );
          }
        }

        // Mark workout completed WITHOUT rewards (historical import)
        try {
          await workoutRepository.markWorkoutCompleted(
            workout.id,
            completedAt: completedAt,
            durationSeconds: durationSeconds,
            notes: notes,
          );
        } catch (_) {
          // Best-effort; records already persisted.
        }
      } catch (e) {
        errors.add(
          RestoreValidationError(
            code: 'workout_restore_failed',
            message: 'Khôi phục workout thất bại: ${wRaw['workout_id']}.',
          ),
        );
      }
    }

    // Restore body measurements
    if (measurementsRaw != null) {
      for (final mRaw in measurementsRaw) {
        if (mRaw is! Map<String, dynamic>) continue;

        try {
          final mId = mRaw['measurement_id'] as String?;
          if (mId == null || mId.isEmpty) continue;

          // BodyMeasurement repository not exposed; skip silently or warn
          warnings.add(
            RestoreValidationWarning(
              code: 'measurement_restore_skipped',
              message: 'Khôi phục body_measurement không được hỗ trợ: $mId.',
            ),
          );
        } catch (_) {
          // Skip silently
        }
      }
    }

    // Record the import fingerprint so a subsequent restore of the same
    // backup is detected as a duplicate.
    if (recordImported != null && errors.isEmpty) {
      await recordImported(backupFingerprint);
    }

    return BackupRestoreResult(
      success: true,
      restoredWorkoutCount: restoredWorkouts,
      restoredExerciseCount: restoredExercises,
      restoredSetCount: restoredSets,
      restoredMeasurementCount: restoredMeasurements,
      skippedDuplicateCount: skippedDuplicates,
      warnings: warnings,
      errors: errors,
    );
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0.0;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _sha1(String input) {
    final bytes = utf8.encode(input);
    var hash = 0x811c9dc5; // FNV offset basis (32-bit)
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x01000193) & 0xFFFFFFFF; // FNV prime
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
