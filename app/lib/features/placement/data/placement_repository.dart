import '../domain/placement_models.dart';

abstract interface class PlacementRepository {
  Future<PlacementState> submit(
    PlacementInput input, {
    required String operationId,
  });
  Future<PlacementState> getState();
}
