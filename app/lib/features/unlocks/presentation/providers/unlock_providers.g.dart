// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All unlock definitions with unlocked/locked state for the current user.

@ProviderFor(UnlocksController)
final unlocksControllerProvider = UnlocksControllerProvider._();

/// All unlock definitions with unlocked/locked state for the current user.
final class UnlocksControllerProvider
    extends $AsyncNotifierProvider<UnlocksController, List<Unlock>> {
  /// All unlock definitions with unlocked/locked state for the current user.
  UnlocksControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlocksControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlocksControllerHash();

  @$internal
  @override
  UnlocksController create() => UnlocksController();
}

String _$unlocksControllerHash() => r'89066317253802cf2bfe5deaf0225c59bc11f01d';

/// All unlock definitions with unlocked/locked state for the current user.

abstract class _$UnlocksController extends $AsyncNotifier<List<Unlock>> {
  FutureOr<List<Unlock>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Unlock>>, List<Unlock>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Unlock>>, List<Unlock>>,
              AsyncValue<List<Unlock>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
