/// P7 Gate 3: reusable CSV import pipeline for workout data.
///
/// Pipeline: input file → format detection → parse → normalize → validate →
/// preview → user confirmation → persistence via existing GymLvl APIs.
///
/// No automatic blind import: every parse produces a preview that must be
/// explicitly confirmed before anything is written. Imported historical
/// workouts grant ZERO XP (complete_workout remains the sole reward path).
///
/// Pure Dart: no credentials, no network, no Supabase in parse/validate.
/// Persistence is injected through [WorkoutRepository] / [ExerciseRepository].
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:app/features/analytics/domain/import_models.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/exercise_repository.dart';
import 'package:app/features/workout/domain/workout_repository.dart';

const double _kgPerLb = 0.45359237;
final RegExp _csvUuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// Kind of resolution to apply when an imported exercise is not in the
/// catalogue.
enum ImportUnknownExercisePolicy {
  /// Map to an existing exercise by name/alias when possible; otherwise skip.
  mapOrSkip,

  /// Create a user-owned custom exercise when no match exists.
  createCustom,
}

/// Reusable CSV import pipeline.
class CsvImportService {
  /// Detect the source format of [content] from its header/structure.
  ImportFormat detectFormat(String content) {
    final lines = _splitLines(content).where((l) => l.trim().isNotEmpty);
    final header = lines.firstOrNull ?? '';
    final lower = header.toLowerCase();

    // GymLvl portable CSV export has a stable header.
    if (lower.contains('workout_id') &&
        lower.contains('workout_exercises') == false &&
        lower.contains('reps')) {
      // Could be either; check for the GymLvl workout header exactly.
      if (lower.contains('started_at') && lower.contains('completed_at')) {
        return ImportFormat.gymLvlCsv;
      }
    }

    // Generic per-set workout CSV: date + exercise + measurements.
    if (lower.contains('date') &&
        (lower.contains('exercise') || lower.contains('workout')) &&
        (lower.contains('reps') ||
            lower.contains('weight') ||
            lower.contains('duration'))) {
      return ImportFormat.genericCsv;
    }

    return ImportFormat.unknown;
  }

  /// Parse [content] into an [ImportPreview]. [fileName] is used for audit and
  /// duplicate-fingerprint context.
  ImportPreview parse(String content, {String? fileName}) {
    final format = detectFormat(content);
    final lines = _splitLines(content);

    switch (format) {
      case ImportFormat.gymLvlCsv:
        return _parseGymLvlCsv(lines, fileName ?? 'import.csv');
      case ImportFormat.genericCsv:
        return _parseGenericCsv(lines, fileName ?? 'import.csv');
      case ImportFormat.unknown:
        return const ImportPreview(
          format: ImportFormat.unknown,
          workouts: [],
          warnings: [],
          validationIssues: [
            ImportValidationIssue(
              code: 'unknown_format',
              message: 'Không nhận diện được định dạng tệp nhập.',
            ),
          ],
        );
    }
  }

  /// Validate a preview against the catalogue. [knownExerciseIds] are the
  /// ids of exercises the user may reference (catalogue + own custom).
  List<ImportValidationIssue> validate(
    ImportPreview preview, {
    Set<String>? knownExerciseIds,
  }) {
    final issues = <ImportValidationIssue>[];
    if (!preview.isValid) {
      issues.addAll(preview.validationIssues);
      return issues;
    }

    for (var w = 0; w < preview.workouts.length; w++) {
      final workout = preview.workouts[w];
      if (workout.exercises.isEmpty) {
        issues.add(
          ImportValidationIssue(
            code: 'workout_without_exercises',
            message: 'Buổi tập không có bài tập nào',
            row: w + 1,
          ),
        );
      }
      for (var e = 0; e < workout.exercises.length; e++) {
        final ex = workout.exercises[e];
        if (knownExerciseIds != null &&
            ex.exerciseId != null &&
            !knownExerciseIds.contains(ex.exerciseId)) {
          issues.add(
            ImportValidationIssue(
              code: 'unknown_exercise',
              message: 'Bài tập "${ex.sourceName}" không tồn tại trong thư mục',
              row: w + 1,
            ),
          );
        }
        for (var s = 0; s < ex.sets.length; s++) {
          final set = ex.sets[s];
          if (set.reps < 0 || set.reps > 1000) {
            issues.add(
              ImportValidationIssue(
                code: 'invalid_reps',
                message: 'Số lần tập không hợp lệ',
                row: w + 1,
              ),
            );
          }
          if (!set.weightKg.isFinite ||
              set.weightKg < 0 ||
              set.weightKg > 1000) {
            issues.add(
              ImportValidationIssue(
                code: 'invalid_weight',
                message: 'Trọng lượng không hợp lệ',
                row: w + 1,
              ),
            );
          }
          if (set.durationSeconds < 0 || set.durationSeconds > 7200) {
            issues.add(
              ImportValidationIssue(
                code: 'invalid_duration',
                message: 'Thời gian không hợp lệ',
                row: w + 1,
              ),
            );
          }
        }
      }
    }

    // Duplicate detection within the file.
    final seenFingerprints = <String>{};
    for (final workout in preview.workouts) {
      final fp = sha256
          .convert(utf8.encode(_workoutContent(workout)))
          .toString();
      if (seenFingerprints.contains(fp)) {
        issues.add(
          ImportValidationIssue(
            code: 'duplicate',
            message: 'Buổi tập trùng lặp trong tệp',
          ),
        );
      }
      seenFingerprints.add(fp);
    }

    return issues;
  }

  /// Confirm a validated preview and persist through [workoutRepository].
  ///
  /// Unknown exercises are resolved per [unknownPolicy]:
  ///   - [ImportUnknownExercisePolicy.mapOrSkip]: map to an existing
  ///     catalogue/custom exercise (by name or alias) or skip with a warning.
  ///   - [ImportUnknownExercisePolicy.createCustom]: create a user-owned
  ///     custom exercise when no match exists.
  ///
  /// Returns an [ImportResult]. Duplicate files (by content fingerprint) are
  /// rejected via [importRecordsRepository] when provided.
  Future<ImportResult> confirm(
    ImportPreview preview, {
    required WorkoutRepository workoutRepository,
    required ExerciseRepository exerciseRepository,
    ImportUnknownExercisePolicy unknownPolicy =
        ImportUnknownExercisePolicy.mapOrSkip,
    String? userId, // owner id (authenticated user)
    String? fileName,
    Future<bool> Function(String fileFingerprint)? isDuplicate,
  }) async {
    final warnings = <ImportWarning>[];
    var importedCount = 0;
    var skippedDuplicates = 0;
    final createdCustomIds = <String>{};

    final importer = workoutRepository;
    if (importer is! HistoricalWorkoutImportRepository) {
      return const ImportResult(
        importedCount: 0,
        warnings: [
          ImportWarning(
            code: 'persistence_error',
            message: 'Không có đường nhập lịch sử an toàn.',
          ),
        ],
      );
    }

    if (validate(preview).isNotEmpty) {
      return const ImportResult(
        importedCount: 0,
        warnings: [
          ImportWarning(
            code: 'validation_error',
            message: 'Dữ liệu nhập không hợp lệ.',
          ),
        ],
      );
    }

    // File-level duplicate guard (fingerprint, not file name).
    final fileContent = json.encode([
      for (final workout in preview.workouts) _workoutContent(workout),
    ]);
    final fileFingerprint =
        'csv:v2:sha256:${sha256.convert(utf8.encode(fileContent))}';
    final legacyContent = preview.workouts
        .map(
          (workout) =>
              '${workout.sourceId}|${workout.startedAt.toIso8601String()}',
        )
        .join(';');
    if (isDuplicate != null &&
        await isDuplicate(_legacyFnvFingerprint(legacyContent))) {
      return const ImportResult(
        importedCount: 0,
        warnings: [
          ImportWarning(
            code: 'legacy_import_requires_review',
            message: 'Bản ghi nhập cũ cần được kiểm tra trước khi thử lại.',
          ),
        ],
      );
    }
    if (isDuplicate != null && await isDuplicate(fileFingerprint)) {
      skippedDuplicates = preview.workouts.length;
      return ImportResult(
        importedCount: 0,
        skippedDuplicates: skippedDuplicates,
        warnings: [
          const ImportWarning(
            code: 'duplicate',
            message:
                'Tệp này đã được nhập trước đó. Bỏ qua để tránh trùng dữ liệu.',
          ),
        ],
      );
    }

    // Build a name → exercise lookup (catalogue + custom).
    final allExercises = <String, Exercise>{};
    try {
      for (final ex in await exerciseRepository.getExercises()) {
        allExercises[ex.name.toLowerCase()] = ex;
        if (ex.nameVi.isNotEmpty) {
          allExercises[ex.nameVi.toLowerCase()] = ex;
        }
        if (ex.nameEn.isNotEmpty) {
          allExercises[ex.nameEn.toLowerCase()] = ex;
        }
      }
    } catch (_) {
      // Read-only catalogue unavailable; proceed with name-only matching.
    }

    for (final workout in preview.workouts) {
      final importedExercises = <ImportedExercise>[];
      var missingTransactionalCustom = false;
      for (
        var sourceOrder = 0;
        sourceOrder < workout.exercises.length;
        sourceOrder++
      ) {
        final ex = workout.exercises[sourceOrder];
        String? resolvedId = ex.exerciseId;
        ImportExerciseResolution resolution =
            ex.resolution ?? ImportExerciseResolution.matched;

        if (resolvedId == null) {
          // Try to resolve by name (catalogue/custom/alias).
          final candidate = allExercises[ex.sourceName.toLowerCase()];
          if (candidate != null && candidate.isArchived == false) {
            resolvedId = candidate.id;
            resolution = ImportExerciseResolution.matched;
          } else if (unknownPolicy ==
              ImportUnknownExercisePolicy.createCustom) {
            if (userId == null || userId.isEmpty) {
              missingTransactionalCustom = true;
              warnings.add(
                ImportWarning(
                  code: 'custom_creation_unavailable',
                  message: 'Cần đăng nhập để tạo bài tập khi nhập.',
                  exerciseName: ex.sourceName,
                ),
              );
            } else {
              final customId = _stableCustomId(
                '$userId|${_workoutContent(workout)}|$sourceOrder',
              );
              importedExercises.add(
                ImportedExercise(
                  sourceName: ex.sourceName,
                  customExerciseId: customId,
                  resolution: ImportExerciseResolution.created,
                  sets: ex.sets,
                  notes: ex.notes,
                  orderIndex: ex.orderIndex,
                ),
              );
            }
          } else {
            resolution = ImportExerciseResolution.skipped;
            warnings.add(
              ImportWarning(
                code: 'unknown_exercise',
                message: 'Bỏ qua bài tập không xác định: "${ex.sourceName}"',
                exerciseName: ex.sourceName,
              ),
            );
          }
        }

        if (resolvedId != null) {
          importedExercises.add(
            ex.copyWith(exerciseId: resolvedId, resolution: resolution),
          );
        }
      }

      if (missingTransactionalCustom) continue;

      if (importedExercises.isEmpty) {
        warnings.add(
          const ImportWarning(
            code: 'no_resolved_exercises',
            message: 'Không có bài tập có thể nhập trong buổi tập.',
          ),
        );
        continue;
      }

      // The server creates a separate completed workout and all children in
      // one transaction. No interactive active session can be reused.
      try {
        final duration = workout.durationSeconds;
        final completedAt = workout.completedAt;
        if (duration == null ||
            duration < 1 ||
            duration > 86400 ||
            completedAt == null ||
            !completedAt.isAfter(workout.startedAt)) {
          warnings.add(
            const ImportWarning(
              code: 'invalid_history',
              message: 'Thiếu thời gian bắt đầu hoặc kết thúc hợp lệ.',
            ),
          );
          continue;
        }
        String? sourceWorkoutId;
        if (preview.format == ImportFormat.gymLvlCsv) {
          if (!_csvUuidPattern.hasMatch(workout.sourceId)) {
            warnings.add(
              const ImportWarning(
                code: 'unsupported_source_workout_id',
                message: 'ID buổi tập nguồn không hợp lệ.',
              ),
            );
            continue;
          }
          sourceWorkoutId = workout.sourceId;
          try {
            if (await workoutRepository.getWorkoutDetail(sourceWorkoutId) !=
                null) {
              warnings.add(
                const ImportWarning(
                  code: 'source_workout_exists',
                  message: 'Buổi tập nguồn đã tồn tại trong tài khoản.',
                ),
              );
              continue;
            }
          } catch (_) {
            warnings.add(
              const ImportWarning(
                code: 'source_workout_lookup_failed',
                message: 'Không thể kiểm tra buổi tập nguồn.',
              ),
            );
            continue;
          }
        }
        final payload = <String, dynamic>{
          'started_at': workout.startedAt.toUtc().toIso8601String(),
          'completed_at': completedAt.toUtc().toIso8601String(),
          'duration_seconds': duration,
          'notes': workout.notes,
          'exercises': [
            for (var order = 0; order < importedExercises.length; order++)
              <String, dynamic>{
                if (importedExercises[order].customExerciseId != null)
                  'custom_exercise': <String, dynamic>{
                    'id': importedExercises[order].customExerciseId,
                    'name': importedExercises[order].sourceName,
                    'category': 'Khác',
                    'equipment': 'Khác',
                  }
                else
                  'exercise_id': importedExercises[order].exerciseId,
                'order_index': order,
                'notes': importedExercises[order].notes,
                'sets': [
                  for (
                    var number = 0;
                    number < importedExercises[order].sets.length;
                    number++
                  )
                    <String, dynamic>{
                      'set_number': number + 1,
                      'reps': importedExercises[order].sets[number].reps,
                      'weight_kg':
                          importedExercises[order].sets[number].weightKg,
                      'duration_seconds':
                          importedExercises[order].sets[number].durationSeconds,
                      'set_type': 'workout',
                      'rest_seconds': 0,
                      'is_completed': true,
                    },
                ],
              },
          ],
        };
        if (sourceWorkoutId != null) {
          payload['source_workout_id'] = sourceWorkoutId;
        }
        final sourceIdentity =
            '${preview.format.name}|${workout.sourceId}|${json.encode(payload)}';
        final importKey =
            'csv:v1:sha256:${sha256.convert(utf8.encode(sourceIdentity))}';
        final receipt = await (importer as HistoricalWorkoutImportRepository)
            .importHistoricalWorkout(importKey: importKey, payload: payload);
        if (receipt.alreadyImported) {
          skippedDuplicates++;
        } else {
          importedCount++;
          createdCustomIds.addAll(receipt.createdCustomExerciseIds);
        }
      } catch (_) {
        warnings.add(
          ImportWarning(
            code: 'persistence_error',
            message: 'Không thể lưu buổi tập',
          ),
        );
      }
    }

    return ImportResult(
      importedCount: importedCount,
      skippedDuplicates: skippedDuplicates,
      warnings: warnings,
      createdCustomExerciseIds: createdCustomIds.toList(),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Parsers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ImportPreview _parseGymLvlCsv(List<String> lines, String fileName) {
    final warnings = <ImportWarning>[];
    // Split the single stream into tables by '# --- name ---' headers.
    final tables = <String, List<Map<String, dynamic>>>{};
    String? currentTable;
    List<String>? headers;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#')) {
        final m = _tableHeaderRegex.firstMatch(trimmed);
        if (m != null) {
          currentTable = m.group(1);
          headers = null;
          tables[currentTable!] = [];
        }
        continue;
      }
      if (currentTable == null) continue;
      if (headers == null) {
        headers = _parseCsvLine(trimmed);
        continue;
      }
      final values = _parseCsvLine(trimmed);
      if (values.length != headers.length) {
        warnings.add(
          ImportWarning(
            code: 'malformed_row',
            message: 'Dòng không khớp số cột trong bảng $currentTable',
          ),
        );
        continue;
      }
      final row = <String, dynamic>{};
      for (var i = 0; i < headers.length; i++) {
        row[headers[i]] = values[i];
      }
      tables[currentTable]!.add(row);
    }

    final workoutsRows = tables['workouts'] ?? <Map<String, dynamic>>[];
    final weRows = tables['workout_exercises'] ?? <Map<String, dynamic>>[];
    final setsRows = tables['workout_sets'] ?? <Map<String, dynamic>>[];

    // Index sets by workout_exercise_id.
    final setsByWe = <String, List<ImportedSet>>{};
    for (final s in setsRows) {
      final weId = s['workout_exercise_id'] as String?;
      if (weId == null) continue;
      final parsed = _parseSetRow(s);
      if (parsed != null) {
        (setsByWe[weId] ??= []).add(parsed);
      }
    }

    // Index workout_exercises by workout_id.
    final weByWorkout = <String, List<Map<String, dynamic>>>{};
    for (final we in weRows) {
      final wid = we['workout_id'] as String?;
      if (wid == null) continue;
      (weByWorkout[wid] ??= []).add(we);
    }

    final workouts = <ImportedWorkout>[];
    for (final w in workoutsRows) {
      final id = w['workout_id'] as String?;
      if (id == null) continue;
      final wes = (weByWorkout[id] ?? <Map<String, dynamic>>[])
        ..sort(
          (a, b) => _parseInt(
            a['order_index'] ?? 0,
          ).compareTo(_parseInt(b['order_index'] ?? 0)),
        );
      final exercises = <ImportedExercise>[];
      var order = 0;
      for (final we in wes) {
        final sets =
            (setsByWe[we['workout_exercise_id'] as String?] ?? <ImportedSet>[])
              ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
        exercises.add(
          ImportedExercise(
            sourceName: we['exercise_name'] as String? ?? 'Bài tập không tên',
            exerciseId: we['exercise_id'] as String?,
            sets: sets,
            notes: we['notes'] as String?,
            orderIndex: order++,
          ),
        );
      }
      workouts.add(
        ImportedWorkout(
          sourceId: id,
          sourceFile: fileName,
          startedAt: _parseDateTime(w['started_at']) ?? DateTime.now(),
          completedAt: _parseDateTime(w['completed_at']),
          durationSeconds: _parseInt(w['duration_seconds']),
          notes: w['notes'] as String?,
          exercises: exercises,
          fingerprint: _workoutFingerprint(
            _parseDateTime(w['started_at']) ?? DateTime.now(),
            exercises,
          ),
        ),
      );
    }

    return ImportPreview(
      format: ImportFormat.gymLvlCsv,
      workouts: workouts,
      warnings: warnings,
    );
  }

  ImportPreview _parseGenericCsv(List<String> lines, String fileName) {
    final warnings = <ImportWarning>[];
    if (lines.isEmpty) {
      return const ImportPreview(
        format: ImportFormat.genericCsv,
        workouts: [],
        warnings: [],
      );
    }

    final headers = _parseCsvLine(
      lines.first,
    ).map((e) => e.toLowerCase()).toList();
    final headerSet = headers.toSet();

    final hasDate = headerSet.contains('date');
    final hasExercise =
        headerSet.contains('exercise') || headerSet.contains('workout');
    if (!hasDate || !hasExercise) {
      return ImportPreview(
        format: ImportFormat.genericCsv,
        workouts: [],
        warnings: [
          const ImportWarning(
            code: 'missing_columns',
            message:
                'Tệp CSV phổ thông cần cột "date" và "exercise" (hoặc "workout")',
          ),
        ],
      );
    }

    // One row per set; group by (date, exercise) into workouts.
    final groups = <String, List<Map<String, dynamic>>>{};
    final groupOrder = <String>[];
    for (var i = 1; i < lines.length; i++) {
      final values = _parseCsvLine(lines[i]);
      if (values.length < headers.length) continue;
      final row = <String, dynamic>{};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = j < values.length ? values[j] : '';
      }
      final date = _toStr(row['date']);
      final exerciseCell = _toStr(row['exercise']);
      final exercise = exerciseCell.isNotEmpty
          ? exerciseCell
          : _toStr(row['workout']);
      final key = '$date|$exercise';
      if (groups.putIfAbsent(key, () => <Map<String, dynamic>>[]).isEmpty) {
        groupOrder.add(key);
      }
      groups[key]!.add(row);
    }

    final workouts = <ImportedWorkout>[];
    for (final key in groupOrder) {
      final parts = key.split('|');
      final date = parts[0];
      final exerciseName = parts.sublist(1).join('|');
      final startedAt = _parseDateTime(date) ?? DateTime.now();
      final rows = groups[key]!;
      rows.sort(
        (a, b) => (_parseInt(
          a['set_number'] ?? 0,
        )).compareTo(_parseInt(b['set_number'] ?? 0)),
      );

      final sets = <ImportedSet>[];
      var durationSeconds = 0;
      for (final row in rows) {
        final parsed = _parseSetRow(row);
        if (parsed != null) sets.add(parsed);
        durationSeconds += parsed?.durationSeconds ?? 0;
      }

      workouts.add(
        ImportedWorkout(
          sourceId: '$date|$exerciseName',
          sourceFile: fileName,
          startedAt: startedAt,
          durationSeconds: durationSeconds > 0 ? durationSeconds : null,
          exercises: [
            ImportedExercise(
              sourceName: exerciseName,
              sets: sets,
              orderIndex: 0,
            ),
          ],
          fingerprint: _workoutFingerprint(startedAt, [
            ImportedExercise(sourceName: exerciseName, sets: sets),
          ]),
        ),
      );
    }

    return ImportPreview(
      format: ImportFormat.genericCsv,
      workouts: workouts,
      warnings: warnings,
    );
  }

  ImportedSet? _parseSetRow(Map<String, dynamic> row) {
    final reps = _parseInt(row['reps'] ?? 0);
    final weightRaw = _toStr(row['weight_kg'] ?? row['weight']);
    final unitRaw = _toStr(row['unit']).toLowerCase();
    final durationSeconds = _parseInt(row['duration_seconds'] ?? 0);

    double weightKg = 0;
    String? unit;
    String? rawWeight;
    String? rawUnit;
    if (weightRaw.isNotEmpty) {
      final parsed = double.tryParse(weightRaw.replaceAll(',', '.'));
      if (parsed == null) return null; // invalid weight
      rawWeight = weightRaw;
      rawUnit = unitRaw.isEmpty ? null : unitRaw;
      switch (unitRaw) {
        case 'lb':
        case 'lbs':
          weightKg = parsed * _kgPerLb;
          unit = 'lb';
        case 'kg':
          weightKg = parsed;
          unit = 'kg';
        case '':
          weightKg = parsed;
          unit = null;
        default:
          // Unknown unit: never silently convert. Keep raw, treat as kg only
          // if explicitly kg; otherwise flag by keeping unit null and value 0.
          weightKg = parsed;
          unit = unitRaw;
      }
    }

    // Validate completed set semantics.
    final isCompleted = _toStr(row['is_completed']).toLowerCase() == 'true';
    if (isCompleted && reps == 0 && durationSeconds == 0 && weightKg == 0) {
      return null; // empty completed set
    }

    return ImportedSet(
      setNumber: _parseInt(row['set_number'] ?? 1),
      reps: reps,
      weightKg: weightKg,
      durationSeconds: durationSeconds,
      unit: unit,
      rawWeight: rawWeight,
      rawUnit: rawUnit,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Helpers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final RegExp _tableHeaderRegex = RegExp(r'^#\s*---\s*([\w_]+)\s*---');

  List<String> _splitLines(String content) =>
      const LineSplitter().convert(content).where((l) => l.isNotEmpty).toList();

  /// Parse one RFC-4180 CSV line into fields (handles quoted fields).
  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    var i = 0;
    final buffer = StringBuffer();
    bool inQuotes = false;
    while (i < line.length) {
      final ch = line[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buffer.writeCharCode('"'.codeUnitAt(0));
            i += 2;
          } else {
            inQuotes = false;
            i++;
          }
        } else {
          buffer.writeCharCode(ch.codeUnitAt(0));
          i++;
        }
      } else {
        if (ch == '"') {
          inQuotes = true;
          i++;
        } else if (ch == ',') {
          fields.add(buffer.toString());
          buffer.clear();
          i++;
        } else {
          buffer.writeCharCode(ch.codeUnitAt(0));
          i++;
        }
      }
    }
    fields.add(buffer.toString());
    return fields;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? 0;
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

  String _toStr(dynamic value) => value == null ? '' : value.toString();

  String _workoutContent(ImportedWorkout workout) => json.encode({
    'source_id': workout.sourceId,
    'started_at': workout.startedAt.toUtc().toIso8601String(),
    'completed_at': workout.completedAt?.toUtc().toIso8601String(),
    'duration_seconds': workout.durationSeconds,
    'notes': workout.notes,
    'exercises': [
      for (final exercise in workout.exercises)
        {
          'exercise_id': exercise.exerciseId,
          'name': exercise.sourceName,
          'notes': exercise.notes,
          'order_index': exercise.orderIndex,
          'sets': [
            for (final set in exercise.sets)
              {
                'set_number': set.setNumber,
                'reps': set.reps,
                'weight_kg': set.weightKg,
                'duration_seconds': set.durationSeconds,
                'notes': set.notes,
              },
          ],
        },
    ],
  });

  String _stableCustomId(String source) {
    final hex = sha256.convert(utf8.encode(source)).toString();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '4${hex.substring(13, 16)}-8${hex.substring(17, 20)}-'
        '${hex.substring(20, 32)}';
  }

  String _workoutFingerprint(
    DateTime startedAt,
    List<ImportedExercise> exercises,
  ) {
    final sig = <String>[];
    sig.add(startedAt.toUtc().toIso8601String());
    for (final ex in exercises) {
      sig.add(ex.sourceName.toLowerCase());
      for (final set in ex.sets) {
        sig.add(
          '${set.reps}x${set.weightKg.toStringAsFixed(2)}x${set.durationSeconds}',
        );
      }
    }
    return _legacyFnvFingerprint(sig.join('|'));
  }

  String _legacyFnvFingerprint(String input) {
    final bytes = utf8.encode(input);
    var hash = 0x811c9dc5; // FNV offset basis (32-bit)
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x01000193) & 0xFFFFFFFF; // FNV prime
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

/// Extension providing `firstOrNull` used by the import service.
extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    for (final e in this) {
      return e;
    }
    return null;
  }
}
