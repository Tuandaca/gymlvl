import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/dashboard_stats.dart';
part 'stats_providers.g.dart';

@riverpod
class DashboardStatsController extends _$DashboardStatsController {
  @override
  FutureOr<DashboardStats?> build() async {
    final userId = ref.watch(
      authStateStreamProvider.select((state) => state.value?.session?.user.id),
    );
    if (userId == null) return null;
    return _fetch();
  }

  Future<DashboardStats> _fetch() async {
    final data = await SupabaseConfig.client.rpc('get_user_stats');
    return DashboardStats.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> refresh() async {
    // Rebuilding lets Riverpod discard results belonging to an old identity.
    ref.invalidateSelf();
  }
}
