import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/post_workout_result.dart';

part 'post_workout_feedback_providers.g.dart';

/// Holds the latest post-workout result to display on the feedback screen.
@riverpod
class PostWorkoutFeedbackController extends _$PostWorkoutFeedbackController {
  @override
  PostWorkoutResult? build() => null;

  /// Set the result from a completed workout. Call this after `complete_workout`
  /// returns successfully.
  void setResult(PostWorkoutResult result) {
    state = result;
  }

  /// Clear the displayed result.
  void clear() {
    state = null;
  }
}
