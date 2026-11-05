// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All catalogue achievements with their earned/locked state for the current user.

@ProviderFor(AchievementsController)
final achievementsControllerProvider = AchievementsControllerProvider._();

/// All catalogue achievements with their earned/locked state for the current user.
final class AchievementsControllerProvider
    extends $AsyncNotifierProvider<AchievementsController, List<Achievement>> {
  /// All catalogue achievements with their earned/locked state for the current user.
  AchievementsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementsControllerHash();

  @$internal
  @override
  AchievementsController create() => AchievementsController();
}

String _$achievementsControllerHash() =>
    r'1703442310d9c1b08b030b707d86b515471b59c1';

/// All catalogue achievements with their earned/locked state for the current user.

abstract class _$AchievementsController
    extends $AsyncNotifier<List<Achievement>> {
  FutureOr<List<Achievement>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Achievement>>, List<Achievement>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Achievement>>, List<Achievement>>,
              AsyncValue<List<Achievement>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
