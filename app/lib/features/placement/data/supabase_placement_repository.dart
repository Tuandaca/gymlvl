import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/placement_models.dart';
import 'placement_repository.dart';

String newPlacementOperationId([Random? random]) {
  final r = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

class SupabasePlacementRepository implements PlacementRepository {
  SupabasePlacementRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<PlacementState> submit(
    PlacementInput input, {
    required String operationId,
  }) async {
    final response = await _client.rpc(
      'submit_placement_assessment_v1',
      params: {'p_operation_id': operationId, 'p_request': input.toRequest()},
    );
    return PlacementState.fromJson(Map<String, dynamic>.from(response as Map));
  }

  @override
  Future<PlacementState> getState() async {
    final response = await _client.rpc('get_placement_state_v1');
    return PlacementState.fromJson(Map<String, dynamic>.from(response as Map));
  }
}
