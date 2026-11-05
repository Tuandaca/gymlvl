// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_workout_feedback_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the latest post-workout result to display on the feedback screen.

@ProviderFor(PostWorkoutFeedbackController)
final postWorkoutFeedbackControllerProvider =
    PostWorkoutFeedbackControllerProvider._();

/// Holds the latest post-workout result to display on the feedback screen.
final class PostWorkoutFeedbackControllerProvider
    extends
        $NotifierProvider<PostWorkoutFeedbackController, PostWorkoutResult?> {
  /// Holds the latest post-workout result to display on the feedback screen.
  PostWorkoutFeedbackControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postWorkoutFeedbackControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postWorkoutFeedbackControllerHash();

  @$internal
  @override
  PostWorkoutFeedbackController create() => PostWorkoutFeedbackController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostWorkoutResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostWorkoutResult?>(value),
    );
  }
}

String _$postWorkoutFeedbackControllerHash() =>
    r'bc062cd0984552548ae334613d3dfdf3eae6e599';

/// Holds the latest post-workout result to display on the feedback screen.

abstract class _$PostWorkoutFeedbackController
    extends $Notifier<PostWorkoutResult?> {
  PostWorkoutResult? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PostWorkoutResult?, PostWorkoutResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PostWorkoutResult?, PostWorkoutResult?>,
              PostWorkoutResult?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
