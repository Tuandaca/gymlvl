import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import 'account_deletion_service.dart';

/// Notifier that drives account deletion for both mobile (Profile) and web
/// (/account/delete). Exposes [AsyncValue<AccountDeletionOutcome>] so callers
/// can render loading / success / deferred / failed states without knowing the
/// HTTP details.
class AccountDeletionNotifier extends AsyncNotifier<AccountDeletionOutcome> {
  late final AccountDeletionService _service;

  @override
  Future<AccountDeletionOutcome> build() async {
    _service = ref.read(accountDeletionServiceProvider);
    // Build returns no outcome until the user explicitly deletes.
    return const AccountDeletionOutcome(AccountDeletionResult.failed);
  }

  /// Deletes the authenticated user's account. Sets [AsyncLoading] while the
  /// request is in flight and stores the typed outcome on completion.
  /// Duplicate submissions while a deletion is in flight are ignored.
  Future<void> deleteAccount() async {
    if (state is AsyncLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _service.deleteAccount());
  }
}

/// Provider exposing [AccountDeletionNotifier].
final accountDeletionNotifierProvider =
    AsyncNotifierProvider<AccountDeletionNotifier, AccountDeletionOutcome>(
      AccountDeletionNotifier.new,
    );

/// Provider exposing the underlying [AccountDeletionService] so both mobile
/// and web share one implementation instance.
final accountDeletionServiceProvider = Provider<AccountDeletionService>((ref) {
  return AccountDeletionService(SupabaseConfig.client);
});
