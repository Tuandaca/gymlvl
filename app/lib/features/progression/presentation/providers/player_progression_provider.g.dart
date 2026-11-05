// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_progression_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Canonical player-progression state aggregated from the server.
///
/// Fields:
/// - [userId], [level], [totalXP], [currentTitle], [lastWorkoutDate]
/// - [streak] (raw JSON from `public.streaks`)
/// - [achievements] (list of earned achievement rows)
/// - [classes] (list of user class rows with currentXP/level)
/// - [activeQuest] (today's active quest instance, or null)
/// - [nextUnlock] (next not-yet-unlocked unlock definition, or null)

@ProviderFor(PlayerProgressionController)
final playerProgressionControllerProvider =
    PlayerProgressionControllerProvider._();

/// Canonical player-progression state aggregated from the server.
///
/// Fields:
/// - [userId], [level], [totalXP], [currentTitle], [lastWorkoutDate]
/// - [streak] (raw JSON from `public.streaks`)
/// - [achievements] (list of earned achievement rows)
/// - [classes] (list of user class rows with currentXP/level)
/// - [activeQuest] (today's active quest instance, or null)
/// - [nextUnlock] (next not-yet-unlocked unlock definition, or null)
final class PlayerProgressionControllerProvider
    extends
        $AsyncNotifierProvider<
          PlayerProgressionController,
          Map<String, dynamic>?
        > {
  /// Canonical player-progression state aggregated from the server.
  ///
  /// Fields:
  /// - [userId], [level], [totalXP], [currentTitle], [lastWorkoutDate]
  /// - [streak] (raw JSON from `public.streaks`)
  /// - [achievements] (list of earned achievement rows)
  /// - [classes] (list of user class rows with currentXP/level)
  /// - [activeQuest] (today's active quest instance, or null)
  /// - [nextUnlock] (next not-yet-unlocked unlock definition, or null)
  PlayerProgressionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerProgressionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerProgressionControllerHash();

  @$internal
  @override
  PlayerProgressionController create() => PlayerProgressionController();
}

String _$playerProgressionControllerHash() =>
    r'0815673e275b979dd319fd7ef4e0a4adfba641fa';

/// Canonical player-progression state aggregated from the server.
///
/// Fields:
/// - [userId], [level], [totalXP], [currentTitle], [lastWorkoutDate]
/// - [streak] (raw JSON from `public.streaks`)
/// - [achievements] (list of earned achievement rows)
/// - [classes] (list of user class rows with currentXP/level)
/// - [activeQuest] (today's active quest instance, or null)
/// - [nextUnlock] (next not-yet-unlocked unlock definition, or null)

abstract class _$PlayerProgressionController
    extends $AsyncNotifier<Map<String, dynamic>?> {
  FutureOr<Map<String, dynamic>?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<String, dynamic>?>, Map<String, dynamic>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, dynamic>?>,
                Map<String, dynamic>?
              >,
              AsyncValue<Map<String, dynamic>?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
