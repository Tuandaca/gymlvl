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
    r'2290aed85dd17930251f5509053a599301974bb1';

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
