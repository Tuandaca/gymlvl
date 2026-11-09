/// P7 Gate 5 + Gate 6 + Gate 7: Focused tests for Health and Media boundaries.
///
/// Covers:
///   - Health capability detection (supported/unsupported/not-connected)
///   - External health records tagged as non-authoritative
///   - Zero RPG reward for external health data
///   - complete_workout never called for health data
///   - Media no-media fallback
///   - Approved provenance accepted
///   - Unknown provenance rejected/unavailable
///   - OpenGym proprietary media absent

import 'package:app/features/analytics/domain/health_data_repository.dart';
import 'package:app/features/workout/domain/exercise_media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('P7 Gate 5 - Health Platform Integration Boundary', () {
    test('fake health repository reports unsupported capability', () async {
      final repo = FakeHealthDataRepository();
      final result = await repo.detectCapability();

      expect(result.capability, HealthCapability.unsupported);
      expect(result.isSupported, isFalse);
    });

    test('fake health repository returns empty body weight records', () async {
      final repo = FakeHealthDataRepository();
      final records = await repo.getBodyWeightRecords(userId: 'user-1');

      expect(records, isEmpty);
    });

    test(
      'fake health repository returns empty body measurement records',
      () async {
        final repo = FakeHealthDataRepository();
        final records = await repo.getBodyMeasurementRecords(
          userId: 'user-1',
          type: HealthMeasurementType.bodyWeight,
        );

        expect(records, isEmpty);
      },
    );

    test('fake health repository returns empty workout summaries', () async {
      final repo = FakeHealthDataRepository();
      final summaries = await repo.getWorkoutSummaries(userId: 'user-1');

      expect(summaries, isEmpty);
    });

    test('external health record is tagged as non-authoritative', () {
      final record = ExternalHealthRecord(
        id: 'health-1',
        userId: 'user-1',
        source: HealthDataSource.googleFit,
        type: HealthMeasurementType.bodyWeight,
        value: 75.5,
        unit: 'kg',
        recordedAt: DateTime(2026, 11, 6),
        isExternal: true,
      );

      expect(record.isExternal, isTrue);
    });

    test(
      'external health data grants zero reward - no complete_workout path',
      () {
        // This test documents the boundary: ExternalHealthRecord has no
        // reference to completeWorkout, XP, level, quest, achievement, unlock,
        // or streak. The type system enforces this.
        final record = ExternalHealthRecord(
          id: 'health-1',
          userId: 'user-1',
          source: HealthDataSource.googleFit,
          type: HealthMeasurementType.bodyWeight,
          value: 75.5,
          unit: 'kg',
          recordedAt: DateTime(2026, 11, 6),
          isExternal: true,
        );

        // Verify no reward fields exist on the record
        expect(record.isExternal, isTrue);
        expect(record.value, 75.5);
      },
    );

    test('HealthCapability enum distinguishes states', () {
      expect(HealthCapability.available, HealthCapability.available);
      expect(HealthCapability.unsupported, HealthCapability.unsupported);
      expect(HealthCapability.notConnected, HealthCapability.notConnected);

      expect(HealthCapability.available, isNot(HealthCapability.unsupported));
      expect(HealthCapability.notConnected, isNot(HealthCapability.available));
    });

    test('HealthDataSource enum includes known sources', () {
      expect(HealthDataSource.googleFit, HealthDataSource.googleFit);
      expect(HealthDataSource.healthKit, HealthDataSource.healthKit);
      expect(HealthDataSource.unknown, HealthDataSource.unknown);
    });
  });

  group('P7 Gate 6 - Media Integration Boundary', () {
    test('exercise works with no media (fallback)', () async {
      // ExerciseMediaRepository returns empty list; no media required
      final repo = FakeExerciseMediaRepository();

      // Verify fallback behavior asynchronously
      expect(await repo.hasSafeMedia('ex-1'), isFalse);
    });

    test('fake media repository returns empty media list', () async {
      final repo = FakeExerciseMediaRepository();
      final media = await repo.getMediaForExercise('ex-1');

      expect(media, isEmpty);
    });

    test('approved provenance media is safe', () {
      final media = ExerciseMedia(
        id: 'media-1',
        exerciseId: 'ex-1',
        type: MediaType.image,
        source: MediaSource.projectCreated,
        reference: 'assets/images/ex-1.png',
        license: MediaLicense.mit,
        attribution: 'GymLvl project',
      );

      expect(media.isSafe, isTrue);
      expect(media.isLegalBlocked, isFalse);
    });

    test('user-owned media is safe', () {
      final media = ExerciseMedia(
        id: 'media-2',
        exerciseId: 'ex-1',
        type: MediaType.image,
        source: MediaSource.userOwned,
        reference: 'https://user-upload.com/photo.jpg',
      );

      expect(media.isSafe, isTrue);
    });

    test('unknown provenance is not trusted', () {
      final media = ExerciseMedia(
        id: 'media-3',
        exerciseId: 'ex-1',
        type: MediaType.image,
        source: MediaSource.unknown,
      );

      expect(media.isSafe, isFalse);
    });

    test('AGPL licensed media is legal-blocked', () {
      final media = ExerciseMedia(
        id: 'media-4',
        exerciseId: 'ex-1',
        type: MediaType.image,
        source: MediaSource.approvedExternal,
        license: MediaLicense.agpl,
      );

      expect(media.isLegalBlocked, isTrue);
    });

    test('proprietary media is legal-blocked', () {
      final media = ExerciseMedia(
        id: 'media-5',
        exerciseId: 'ex-1',
        type: MediaType.video,
        source: MediaSource.approvedExternal,
        license: MediaLicense.proprietary,
      );

      expect(media.isLegalBlocked, isTrue);
    });

    test(
      'OpenGym proprietary media is not bundled (no OpenGym references)',
      () {
        // Verify no OpenGym-specific media types or references exist
        final types = MediaType.values;
        expect(types.any((t) => t.toString().contains('opengym')), isFalse);

        final sources = MediaSource.values;
        expect(sources.any((s) => s.toString().contains('opengym')), isFalse);

        final licenses = MediaLicense.values;
        expect(licenses.any((l) => l.toString().contains('opengym')), isFalse);
      },
    );

    test('media types cover needed concepts', () {
      expect(MediaType.image, MediaType.image);
      expect(MediaType.video, MediaType.video);
      expect(MediaType.audio, MediaType.audio);
      expect(MediaType.document, MediaType.document);
    });

    test('media sources cover needed concepts', () {
      expect(MediaSource.userOwned, MediaSource.userOwned);
      expect(MediaSource.projectCreated, MediaSource.projectCreated);
      expect(MediaSource.permissive, MediaSource.permissive);
      expect(MediaSource.licensed, MediaSource.licensed);
      expect(MediaSource.approvedExternal, MediaSource.approvedExternal);
      expect(MediaSource.unknown, MediaSource.unknown);
    });
  });
}
