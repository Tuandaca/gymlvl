import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/dashboard_stats.dart';

part 'stats_providers.g.dart';

@riverpod
class DashboardStatsController extends _$DashboardStatsController {
  @override
  FutureOr<DashboardStats?> build() async {
    return _fetchStats();
  }

  Future<DashboardStats?> _fetchStats() async {
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'get-user-stats',
        method: HttpMethod.post,
      );

      if (response.status == 200) {
        return DashboardStats.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}
