// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveQuestController)
final activeQuestControllerProvider = ActiveQuestControllerProvider._();

final class ActiveQuestControllerProvider
    extends $AsyncNotifierProvider<ActiveQuestController, QuestInstance?> {
  ActiveQuestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeQuestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeQuestControllerHash();

  @$internal
  @override
  ActiveQuestController create() => ActiveQuestController();
}

String _$activeQuestControllerHash() =>
    r'1f0940d947c63cd2e80c98903fe1d272c3b9a3d2';

abstract class _$ActiveQuestController extends $AsyncNotifier<QuestInstance?> {
  FutureOr<QuestInstance?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<QuestInstance?>, QuestInstance?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuestInstance?>, QuestInstance?>,
              AsyncValue<QuestInstance?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
