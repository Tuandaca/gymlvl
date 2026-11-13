import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../data/placement_repository.dart';
import '../data/supabase_placement_repository.dart';
import '../domain/placement_models.dart';

final placementRepositoryProvider = Provider<PlacementRepository>((ref) {
  return SupabasePlacementRepository(Supabase.instance.client);
});

final placementStateProvider = FutureProvider<PlacementState>((ref) async {
  ref.watch(authStateStreamProvider.select((a) => a.value?.session?.user.id));
  return ref.read(placementRepositoryProvider).getState();
});

class PlacementOnboardingDraft {
  const PlacementOnboardingDraft({this.input, this.operationId});
  final PlacementInput? input;
  final String? operationId;
  PlacementOnboardingDraft copyWith({
    PlacementInput? input,
    String? operationId,
  }) => PlacementOnboardingDraft(
    input: input ?? this.input,
    operationId: operationId ?? this.operationId,
  );
}

final placementOnboardingDraftProvider =
    NotifierProvider<
      PlacementOnboardingDraftNotifier,
      PlacementOnboardingDraft
    >(PlacementOnboardingDraftNotifier.new);

class PlacementOnboardingDraftNotifier
    extends Notifier<PlacementOnboardingDraft> {
  @override
  PlacementOnboardingDraft build() {
    ref.watch(authStateStreamProvider.select((a) => a.value?.session?.user.id));
    return const PlacementOnboardingDraft();
  }

  void setInput(PlacementInput input) {
    final normalized = input.toRequest().toString();
    final previous = state.input?.toRequest().toString();
    state = PlacementOnboardingDraft(
      input: input,
      operationId: normalized == previous
          ? state.operationId
          : newPlacementOperationId(),
    );
  }

  void clear() => state = const PlacementOnboardingDraft();
}

final placementSubmitControllerProvider =
    AsyncNotifierProvider<PlacementSubmitController, PlacementState?>(
      PlacementSubmitController.new,
    );

class PlacementSubmitController extends AsyncNotifier<PlacementState?> {
  int _generation = 0;
  @override
  FutureOr<PlacementState?> build() {
    ref.watch(authStateStreamProvider.select((a) => a.value?.session?.user.id));
    _generation++;
    return null;
  }

  Future<void> submit() async {
    final draft = ref.read(placementOnboardingDraftProvider);
    final input = draft.input;
    if (input == null) throw StateError('Placement input is required');
    final operationId = draft.operationId ?? newPlacementOperationId();
    final generation = _generation;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(placementRepositoryProvider)
          .submit(input, operationId: operationId),
    );
    if (!ref.mounted || generation != _generation) return;
    state = result;
    if (!result.hasError) ref.invalidate(placementStateProvider);
  }
}
