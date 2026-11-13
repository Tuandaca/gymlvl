/// P7 Gate 4: Backup restore / GymLvl portable import.
///
/// Restores a previously exported GymLvl backup (format "gymlvl-backup",
/// versions 1 and 2). Strict validation, preview before confirmation, deterministic
/// idempotent restore, and zero retroactive rewards for historical workouts.
///
/// Uses the P4 BackupExportService schema as authority. Never restores
/// passwords, tokens, secrets, or arbitrary RPG state.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:app/features/workout/domain/exercise_repository.dart';
import 'package:app/features/workout/domain/workout_repository.dart';

const String kBackupFormat = 'gymlvl-backup';
const int kBackupVersion = 1;
const int kBackupVersion2 = 2;
final RegExp _backupUuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

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
    if (version is! int ||
        (version != kBackupVersion && version != kBackupVersion2)) {
      errors.add(
        RestoreValidationError(
          code: 'unsupported_version',
          message: 'Phiên bản không được hỗ trợ: $version.',
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

    final dataMap = data;

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

      for (final dateField in [
        'started_at',
        'completed_at',
        'created_at',
        'updated_at',
      ]) {
        if (w[dateField] != null && _parseDateTime(w[dateField]) == null) {
          errors.add(
            RestoreValidationError(
              code: 'invalid_date',
              message: 'Invalid workout date.',
              section: 'data.workouts[$i].$dateField',
            ),
          );
        }
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

          final orderIndex = we['order_index'];
          if (orderIndex is! int || orderIndex < 0) {
            errors.add(
              RestoreValidationError(
                code: 'invalid_order_index',
                message: 'Thứ tự bài tập không hợp lệ.',
                section: 'data.workout_exercises[$i].order_index',
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

    for (final exercise in weList) {
      if (!workoutIds.contains(exercise['workout_id'])) {
        errors.add(
          const RestoreValidationError(
            code: 'orphan_workout_exercise',
            message: 'Workout exercise references a missing workout.',
            section: 'data.workout_exercises',
          ),
        );
      }
    }
    for (final set in setsList) {
      if (!weIds.contains(set['workout_exercise_id'])) {
        errors.add(
          const RestoreValidationError(
            code: 'orphan_workout_set',
            message: 'Workout set references a missing exercise.',
            section: 'data.workout_sets',
          ),
        );
      }
    }
    final preferences = dataMap['preferences'];
    final customExercises = dataMap['custom_exercises'];
    final customList = <Map<String, dynamic>>[];
    final customIds = <String>{};
    if (version == kBackupVersion2) {
      if (customExercises is! List || preferences != null) {
        errors.add(
          const RestoreValidationError(
            code: 'invalid_v2_sections',
            message: 'Backup v2 sections are invalid.',
          ),
        );
      } else {
        for (final raw in customExercises) {
          if (raw is! Map<String, dynamic> ||
              raw['id'] is! String ||
              raw['user_id'] != userId ||
              raw['source'] != 'user' ||
              raw.containsKey('image_url') ||
              raw.containsKey('external_id') ||
              raw.containsKey('source_revision') ||
              !customIds.add(raw['id'] as String)) {
            errors.add(
              const RestoreValidationError(
                code: 'invalid_custom_definition',
                message: 'Backup custom definition is invalid.',
              ),
            );
          } else {
            customList.add(raw);
          }
        }
      }
    }
    if (version == 1 &&
        ((preferences is Map && preferences.isNotEmpty) ||
            (customExercises is List && customExercises.isNotEmpty) ||
            workouts.any((w) => w['status'] != 'completed') ||
            weList.any(
              (we) =>
                  we['superset_group_id'] != null ||
                  we['superset_position'] != null ||
                  we['mode'] != null,
            ) ||
            setsList.any(
              (set) =>
                  (set['baseline_weight_kg'] != null &&
                      set['baseline_weight_kg'] != 0) ||
                  set['rpe'] != null ||
                  set['rir'] != null,
            ))) {
      errors.add(
        const RestoreValidationError(
          code: 'unsupported_backup_data',
          message: 'Backup contains data that cannot be restored safely.',
        ),
      );
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
      customExerciseCount: customList.length,
      recordStatuses: [
        ...customList.map(
          (custom) => RestoreRecordPreview(
            recordType: 'custom_exercise',
            sourceId: custom['id'] as String,
            status: RestoreRecordStatus.newRecord,
          ),
        ),
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

  /// Restore only fields that the authenticated historical-import RPC can
  /// preserve. Unsupported backup data fails before any workout is written.
  Future<BackupRestoreResult> restore({
    required String jsonContent,
    required String currentUserId,
    Future<bool> Function(String backupFingerprint)? isDuplicate,
    Future<void> Function(String backupFingerprint)? recordImported,
  }) async {
    final checked = preview(jsonContent);
    if (!checked.canRestore) {
      return BackupRestoreResult(
        success: false,
        errors: checked.validationResult.errors,
      );
    }

    final parsed = json.decode(jsonContent) as Map<String, dynamic>;
    final data = parsed['data'] as Map<String, dynamic>;
    final version = parsed['version'] as int;
    const invalidOwner = RestoreValidationError(
      code: 'owner_mismatch',
      message: 'Backup owner does not match the signed-in account.',
    );
    const unsupported = RestoreValidationError(
      code: 'unsupported_backup_data',
      message: 'Backup contains data that cannot be restored safely.',
    );
    String? authenticatedOwner;
    try {
      if (workoutRepository is HistoricalImportIdentity) {
        authenticatedOwner =
            (workoutRepository as HistoricalImportIdentity).authenticatedUserId;
      }
    } catch (_) {
      // A missing or expired session cannot authorize a same-owner restore.
    }
    if (currentUserId.isEmpty ||
        data['user_id'] != currentUserId ||
        authenticatedOwner != currentUserId) {
      return const BackupRestoreResult(success: false, errors: [invalidOwner]);
    }

    final importer = workoutRepository;
    if (importer is! HistoricalWorkoutImportRepository) {
      return const BackupRestoreResult(
        success: false,
        errors: [
          RestoreValidationError(
            code: 'historical_import_unavailable',
            message: 'Secure historical import is unavailable.',
          ),
        ],
      );
    }

    final workouts = (data['workouts'] as List).cast<Map<String, dynamic>>();
    final exercises = (data['workout_exercises'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final sets = (data['workout_sets'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final measurements = data['body_measurements'] as List? ?? const [];
    final customExercises = data['custom_exercises'] as List? ?? const [];
    final customIds = customExercises
        .map((raw) => (raw as Map<String, dynamic>)['id'])
        .toSet();
    final preferences = data['preferences'] as Map?;
    if ((version == kBackupVersion && customExercises.isNotEmpty) ||
        (preferences?.isNotEmpty ?? false)) {
      return const BackupRestoreResult(success: false, errors: [unsupported]);
    }
    if (customExercises.isNotEmpty &&
        importer is! HistoricalCustomExerciseImportRepository) {
      return const BackupRestoreResult(success: false, errors: [unsupported]);
    }
    if (measurements.isNotEmpty &&
        importer is! HistoricalMeasurementImportRepository) {
      return const BackupRestoreResult(success: false, errors: [unsupported]);
    }

    final workoutIds = workouts.map((w) => w['workout_id']).toSet();
    final exerciseIds = exercises.map((e) => e['workout_exercise_id']).toSet();
    for (final workout in workouts) {
      final started = _parseDateTime(workout['started_at']);
      final completed = _parseDateTime(workout['completed_at']);
      final duration = workout['duration_seconds'];
      if (workout['user_id'] != currentUserId) {
        return const BackupRestoreResult(
          success: false,
          errors: [invalidOwner],
        );
      }
      if (workout['status'] != 'completed' ||
          started == null ||
          completed == null ||
          !completed.isAfter(started) ||
          duration is! int ||
          duration < 1 ||
          duration > 86400 ||
          (version == kBackupVersion2 &&
              (workout['paused_at'] != null ||
                  workout['paused_seconds'] is! int ||
                  (workout['paused_seconds'] as int) < 0 ||
                  (workout['training_started_at'] != null &&
                      (_parseDateTime(workout['training_started_at']) == null ||
                          _parseDateTime(
                            workout['training_started_at'],
                          )!.isBefore(started) ||
                          _parseDateTime(
                            workout['training_started_at'],
                          )!.isAfter(completed)))))) {
        return const BackupRestoreResult(success: false, errors: [unsupported]);
      }
    }
    final seenOrders = <String>{};
    for (final exercise in exercises) {
      if (!workoutIds.contains(exercise['workout_id']) ||
          exercise['exercise_id'] is! String ||
          (exercise['exercise_id'] as String).isEmpty ||
          exercise['order_index'] is! int ||
          (exercise['order_index'] as int) < 0 ||
          (version == kBackupVersion &&
              (exercise['superset_group_id'] != null ||
                  exercise['superset_position'] != null ||
                  exercise['mode'] != null)) ||
          (version == kBackupVersion2 &&
              ((exercise['superset_group_id'] == null) !=
                      (exercise['superset_position'] == null) ||
                  (exercise['superset_position'] != null &&
                      exercise['superset_position'] is! int) ||
                  (exercise['superset_locked'] != null &&
                      exercise['superset_locked'] is! bool) ||
                  (exercise['mode'] != null &&
                      !const [
                        'reps-weight',
                        'bodyweight',
                        'timed',
                        'cardio',
                      ].contains(exercise['mode'])) ||
                  exercise['exercise_source'] is! String ||
                  (exercise['exercise_source'] == 'user' &&
                      !customIds.contains(exercise['exercise_id']))))) {
        return const BackupRestoreResult(success: false, errors: [unsupported]);
      }
      if (!seenOrders.add(
        '${exercise['workout_id']}|${exercise['order_index']}',
      )) {
        return const BackupRestoreResult(success: false, errors: [unsupported]);
      }
    }
    final seenSetNumbers = <String>{};
    for (final set in sets) {
      if (!exerciseIds.contains(set['workout_exercise_id']) ||
          set['set_number'] is! int ||
          (set['set_number'] as int) < 1 ||
          set['reps'] is! int ||
          set['weight_kg'] is! num ||
          set['duration_seconds'] is! int ||
          (set['is_completed'] != null && set['is_completed'] is! bool) ||
          (set['rest_seconds'] != null && set['rest_seconds'] is! int) ||
          (set['set_type'] != null &&
              set['set_type'] != 'workout' &&
              set['set_type'] != 'warmup') ||
          (version == kBackupVersion &&
              ((set['baseline_weight_kg'] != null &&
                      set['baseline_weight_kg'] != 0) ||
                  set['rpe'] != null ||
                  set['rir'] != null)) ||
          (version == kBackupVersion2 &&
              (set['baseline_weight_kg'] is! num ||
                  (set['rpe'] != null && set['rpe'] is! int) ||
                  (set['rir'] != null && set['rir'] is! int)))) {
        return const BackupRestoreResult(success: false, errors: [unsupported]);
      }
      if (!seenSetNumbers.add(
        '${set['workout_exercise_id']}|${set['set_number']}',
      )) {
        return const BackupRestoreResult(success: false, errors: [unsupported]);
      }
    }
    if (version == kBackupVersion2) {
      const textFields = [
        'id',
        'name',
        'category',
        'equipment',
        'slug',
        'name_vi',
        'name_en',
      ];
      const arrayFields = [
        'instructions',
        'secondary_muscles',
        'form_cues',
        'common_mistakes',
        'alternative_exercise_slugs',
      ];
      for (final raw in customExercises) {
        final custom = raw as Map<String, dynamic>;
        if (custom['user_id'] != currentUserId ||
            custom['source'] != 'user' ||
            custom['is_archived'] is! bool ||
            textFields.any((field) => custom[field] is! String) ||
            arrayFields.any(
              (field) =>
                  custom[field] is! List ||
                  (custom[field] as List).any((item) => item is! String),
            )) {
          return const BackupRestoreResult(
            success: false,
            errors: [unsupported],
          );
        }
      }
    }
    for (final raw in measurements) {
      final measurement = raw as Map<String, dynamic>;
      final value = measurement['value'];
      if (measurement['user_id'] != currentUserId) {
        return const BackupRestoreResult(
          success: false,
          errors: [invalidOwner],
        );
      }
      if (measurement['measurement_id'] is! String ||
          measurement['measurement_type'] is! String ||
          value is! num ||
          !value.isFinite ||
          value <= 0 ||
          value > 1000 ||
          measurement['unit'] is! String ||
          _parseDateTime(measurement['measured_at']) == null) {
        return const BackupRestoreResult(success: false, errors: [unsupported]);
      }
    }

    // Same-account backups usually contain the original workout already.
    // Refuse to clone it; a missing result is required before any import RPC.
    for (final workout in workouts) {
      final sourceId = workout['workout_id'] as String;
      if (!_backupUuidPattern.hasMatch(sourceId)) {
        return const BackupRestoreResult(
          success: false,
          errors: [
            RestoreValidationError(
              code: 'unsupported_source_workout_id',
              message: 'Backup workout identity is not a UUID.',
            ),
          ],
        );
      }
      try {
        if (await workoutRepository.getWorkoutDetail(sourceId) != null) {
          return const BackupRestoreResult(
            success: false,
            errors: [
              RestoreValidationError(
                code: 'source_workout_exists',
                message: 'Source workout already exists in this account.',
              ),
            ],
          );
        }
      } catch (_) {
        return const BackupRestoreResult(
          success: false,
          errors: [
            RestoreValidationError(
              code: 'source_workout_lookup_failed',
              message: 'Source workout could not be checked.',
            ),
          ],
        );
      }
    }

    final fingerprint = version == 2
        ? 'backup:v2:sha256:${sha256.convert(utf8.encode(json.encode(_canonicalValue(data))))}'
        : 'backup:v1:sha256:${sha256.convert(utf8.encode(jsonContent))}';
    if (version == kBackupVersion &&
        isDuplicate != null &&
        await isDuplicate(_legacyFnvFingerprint(jsonContent))) {
      return const BackupRestoreResult(
        success: false,
        errors: [
          RestoreValidationError(
            code: 'legacy_import_requires_review',
            message: 'Older import record requires review before retry.',
          ),
        ],
      );
    }
    if (isDuplicate != null && await isDuplicate(fingerprint)) {
      return const BackupRestoreResult(
        success: true,
        skippedDuplicateCount: 1,
        warnings: [
          RestoreValidationWarning(
            code: 'already_imported',
            message: 'This backup was already imported.',
          ),
        ],
      );
    }

    var restoredWorkouts = 0;
    var restoredExercises = 0;
    var restoredSets = 0;
    var restoredMeasurements = 0;
    var restoredCustomExercises = 0;
    var skippedDuplicates = 0;
    final errors = <RestoreValidationError>[];
    if (version == kBackupVersion2 && customExercises.isNotEmpty) {
      final customImporter =
          importer as HistoricalCustomExerciseImportRepository;
      for (final raw in customExercises) {
        final custom = raw as Map<String, dynamic>;
        final sourceId = custom['id'] as String;
        final payload = <String, dynamic>{
          for (final field in [
            'id',
            'name',
            'category',
            'equipment',
            'force_type',
            'mechanic',
            'instructions',
            'slug',
            'name_vi',
            'name_en',
            'movement_pattern',
            'secondary_muscles',
            'difficulty',
            'form_cues',
            'common_mistakes',
            'alternative_exercise_slugs',
            'is_archived',
          ])
            field: custom[field],
        };
        final key =
            'backup:custom:sha256:'
            '${sha256.convert(utf8.encode('$currentUserId|$sourceId'))}';
        try {
          final receipt = await customImporter.importCustomExercise(
            importKey: key,
            payload: payload,
          );
          if (receipt.exerciseId != sourceId) {
            throw StateError('custom_import_identity_mismatch');
          }
          if (receipt.alreadyImported) {
            skippedDuplicates++;
          } else if (receipt.created) {
            restoredCustomExercises++;
          }
        } catch (_) {
          errors.add(
            const RestoreValidationError(
              code: 'custom_restore_failed',
              message: 'Custom exercise could not be restored.',
            ),
          );
          return BackupRestoreResult(
            success: false,
            restoredCustomExerciseCount: restoredCustomExercises,
            skippedDuplicateCount: skippedDuplicates,
            errors: errors,
          );
        }
      }
    }
    for (final workout in workouts) {
      final workoutId = workout['workout_id'] as String;
      final children =
          exercises
              .where((exercise) => exercise['workout_id'] == workoutId)
              .toList()
            ..sort(
              (a, b) =>
                  (a['order_index'] as int).compareTo(b['order_index'] as int),
            );
      final payload = <String, dynamic>{
        'source_workout_id': workoutId,
        'started_at': _parseDateTime(
          workout['started_at'],
        )!.toUtc().toIso8601String(),
        'completed_at': _parseDateTime(
          workout['completed_at'],
        )!.toUtc().toIso8601String(),
        'duration_seconds': workout['duration_seconds'],
        'notes': workout['notes'],
        if (version == kBackupVersion2) ...{
          'training_started_at': workout['training_started_at'],
          'paused_seconds': workout['paused_seconds'],
        },
        'exercises': [
          for (final exercise in children)
            <String, dynamic>{
              'exercise_id': exercise['exercise_id'],
              'order_index': exercise['order_index'],
              'notes': exercise['notes'],
              if (version == kBackupVersion2) ...{
                'mode': exercise['mode'],
                'superset_group_id': exercise['superset_group_id'],
                'superset_position': exercise['superset_position'],
                if (exercise['superset_locked'] != null)
                  'superset_locked': exercise['superset_locked'],
                'exercise_source': exercise['exercise_source'],
                'exercise_external_id': exercise['exercise_external_id'],
                'exercise_source_revision':
                    exercise['exercise_source_revision'],
              },
              'sets': [
                for (final set in sets.where(
                  (set) =>
                      set['workout_exercise_id'] ==
                      exercise['workout_exercise_id'],
                ))
                  <String, dynamic>{
                    'set_number': set['set_number'],
                    'reps': set['reps'],
                    'weight_kg': set['weight_kg'],
                    'duration_seconds': set['duration_seconds'],
                    'is_completed': set['is_completed'] ?? false,
                    'set_type': set['set_type'] ?? 'workout',
                    'rest_seconds': set['rest_seconds'] ?? 0,
                    if (version == kBackupVersion2) ...{
                      'baseline_weight_kg': set['baseline_weight_kg'],
                      'rpe': set['rpe'],
                      'rir': set['rir'],
                    },
                  },
              ],
            },
        ],
      };
      // Share identity across backup versions. A richer reimport of the same
      // source UUID conflicts on the server digest instead of cloning history.
      final key =
          'backup:workout:sha256:'
          '${sha256.convert(utf8.encode('$currentUserId|$workoutId'))}';
      try {
        final receipt = await (importer as HistoricalWorkoutImportRepository)
            .importHistoricalWorkout(importKey: key, payload: payload);
        if (receipt.alreadyImported) {
          skippedDuplicates++;
        } else {
          restoredWorkouts++;
          restoredExercises += children.length;
          restoredSets += children.fold<int>(
            0,
            (count, exercise) =>
                count +
                sets
                    .where(
                      (set) =>
                          set['workout_exercise_id'] ==
                          exercise['workout_exercise_id'],
                    )
                    .length,
          );
        }
      } catch (_) {
        errors.add(
          const RestoreValidationError(
            code: 'workout_restore_failed',
            message: 'Historical workout could not be restored.',
          ),
        );
      }
    }

    if (importer is HistoricalMeasurementImportRepository) {
      for (final raw in measurements) {
        final measurement = raw as Map<String, dynamic>;
        final payload = <String, dynamic>{
          'measurement_type': measurement['measurement_type'],
          'value': measurement['value'],
          'unit': measurement['unit'],
          'measured_at': _parseDateTime(
            measurement['measured_at'],
          )!.toUtc().toIso8601String(),
          'notes': measurement['notes'],
        };
        final source = measurement['measurement_id'] as String;
        final key =
            'backup:v1:measurement:sha256:'
            '${sha256.convert(utf8.encode('$currentUserId|$source'))}';
        try {
          final receipt =
              await (importer as HistoricalMeasurementImportRepository)
                  .importHistoricalMeasurement(
                    importKey: key,
                    payload: payload,
                  );
          if (receipt.alreadyImported) {
            skippedDuplicates++;
          } else {
            restoredMeasurements++;
          }
        } catch (_) {
          errors.add(
            const RestoreValidationError(
              code: 'measurement_restore_failed',
              message: 'Historical measurement could not be restored.',
            ),
          );
        }
      }
    }

    if (errors.isEmpty && recordImported != null) {
      try {
        await recordImported(fingerprint);
      } catch (_) {
        errors.add(
          const RestoreValidationError(
            code: 'import_record_failed',
            message: 'Backup import receipt could not be recorded.',
          ),
        );
      }
    }
    return BackupRestoreResult(
      success: errors.isEmpty,
      restoredWorkoutCount: restoredWorkouts,
      restoredExerciseCount: restoredExercises,
      restoredSetCount: restoredSets,
      restoredMeasurementCount: restoredMeasurements,
      restoredCustomExerciseCount: restoredCustomExercises,
      skippedDuplicateCount: skippedDuplicates,
      errors: errors,
    );
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

  dynamic _canonicalValue(dynamic value) {
    if (value is Map) {
      final map = value.cast<String, dynamic>();
      return <String, dynamic>{
        for (final key in map.keys.toList()..sort())
          key: _canonicalValue(map[key]),
      };
    }
    if (value is List) return value.map(_canonicalValue).toList();
    return value;
  }

  String _legacyFnvFingerprint(String input) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(input)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
