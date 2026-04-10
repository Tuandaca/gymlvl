import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/quest_instance.dart';

part 'quest_providers.g.dart';

@riverpod
class ActiveQuestController extends _$ActiveQuestController {
  @override
  FutureOr<QuestInstance?> build() async {
    return _fetchOrSyncQuest();
  }

  Future<QuestInstance?> _fetchOrSyncQuest() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) return null;

      // 1. Kiểm tra quest của ngày hôm nay (Dựa trên status active)
      final existingResponse = await SupabaseConfig.client
          .from('quest_instances')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existingResponse != null) {
        return QuestInstance.fromJson(existingResponse);
      }

      // 2. Nếu không có, gọi Edge Function để gán mới
      final syncResponse = await SupabaseConfig.client.functions.invoke(
        'sync-daily-data',
        method: HttpMethod.post,
      );

      if (syncResponse.status == 200) {
        final data = syncResponse.data;
        
        // Trường hợp Quest mới được tạo
        if (data['quest'] != null) {
          return QuestInstance.fromJson(data['quest']);
        }
        
        // Trường hợp Quest đã tồn tại (Backend báo message)
        if (data['message'] != null && data['message'].toString().contains('exists')) {
           // Thử fetch lại một lần nữa
           final reFetch = await SupabaseConfig.client
            .from('quest_instances')
            .select()
            .eq('user_id', userId)
            .eq('status', 'active')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
            
           if (reFetch != null) return QuestInstance.fromJson(reFetch);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchOrSyncQuest());
  }
}
