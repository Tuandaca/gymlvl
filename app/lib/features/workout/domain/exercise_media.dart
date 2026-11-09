/// P7 Gate 6: Optional media integration boundary.
///
/// Minimal media metadata/provenance support for future legally approved
/// exercise media. Does NOT import or bundle OpenGym proprietary media.
/// Unknown provenance is never automatically trusted.
library;

/// Type of exercise media.
enum MediaType { image, video, audio, document }

/// Source of media.
enum MediaSource {
  userOwned,
  projectCreated,
  permissive,
  licensed,
  approvedExternal,

  /// Unknown / unvetted provenance. Never trusted automatically.
  unknown,
}

/// License type for media.
enum MediaLicense { mit, agpl, proprietary, permissive, unknown }

/// Media metadata attached to an exercise. Does NOT store media files.
class ExerciseMedia {
  const ExerciseMedia({
    required this.id,
    required this.exerciseId,
    required this.type,
    required this.source,
    this.reference,
    this.license,
    this.attribution,
    this.createdAt,
  });

  final String id;
  final String exerciseId;
  final MediaType type;
  final MediaSource source;
  final String? reference; // URL / asset path
  final MediaLicense? license;
  final String? attribution;
  final DateTime? createdAt;

  ExerciseMedia copyWith({
    String? id,
    String? exerciseId,
    MediaType? type,
    MediaSource? source,
    String? reference,
    MediaLicense? license,
    String? attribution,
    DateTime? createdAt,
  }) {
    return ExerciseMedia(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      type: type ?? this.type,
      source: source ?? this.source,
      reference: reference ?? this.reference,
      license: license ?? this.license,
      attribution: attribution ?? this.attribution,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether this media entry is safe to display.
  ///
  /// Unknown provenance is not trusted. AGPL / proprietary OpenGym media
  /// is blocked.
  bool get isSafe {
    switch (source) {
      case MediaSource.userOwned:
      case MediaSource.projectCreated:
      case MediaSource.permissive:
      case MediaSource.licensed:
      case MediaSource.approvedExternal:
        return true;
      case MediaSource.unknown:
        return false;
    }
  }

  /// Whether this media entry is LEGAL-BLOCKED (OpenGym proprietary / AGPL).
  bool get isLegalBlocked {
    switch (source) {
      case MediaSource.unknown:
      case MediaSource.approvedExternal:
        return license == MediaLicense.agpl ||
            license == MediaLicense.proprietary;
      default:
        return false;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseMedia &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => Object.hash(id, runtimeType);

  @override
  String toString() =>
      'ExerciseMedia(id: $id, exerciseId: $exerciseId, type: $type, source: $source, safe: $isSafe)';
}

/// Repository abstraction for exercise media metadata.
abstract class ExerciseMediaRepository {
  /// All media metadata for an exercise.
  Future<List<ExerciseMedia>> getMediaForExercise(String exerciseId);

  /// Whether any safe media exists for an exercise.
  Future<bool> hasSafeMedia(String exerciseId);
}

/// Fake implementation: no media available, fallback placeholder always used.
class FakeExerciseMediaRepository extends ExerciseMediaRepository {
  @override
  Future<List<ExerciseMedia>> getMediaForExercise(String exerciseId) async =>
      const [];

  @override
  Future<bool> hasSafeMedia(String exerciseId) async => false;
}
