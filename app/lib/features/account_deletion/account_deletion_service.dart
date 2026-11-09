import 'package:supabase_flutter/supabase_flutter.dart';

/// Outcome of an account-deletion request.
///
/// The delete-account Edge Function distinguishes three server-reported
/// states:
///
/// * [success] — public data deleted and Supabase Auth user removed
///   (HTTP 200).
/// * [deferred] — public data deleted but Auth deletion could not complete
///   (HTTP 202 `auth_row_removal_deferred`). Cleanup is pending and a retry
///   is safe.
/// * [failed] — deletion could not proceed (HTTP 500 or transport error).
enum AccountDeletionResult { success, deferred, failed }

/// Typed result of an account-deletion attempt.
class AccountDeletionOutcome {
  final AccountDeletionResult result;
  final String? message;

  const AccountDeletionOutcome(this.result, {this.message});

  bool get isSuccess => result == AccountDeletionResult.success;
  bool get isDeferred => result == AccountDeletionResult.deferred;
  bool get isFailed => result == AccountDeletionResult.failed;
}

/// Smallest reusable account-deletion boundary shared by mobile (Profile) and
/// web (/account/delete). Wraps the delete-account Edge Function so both
/// platforms invoke the same backend contract without duplicating HTTP logic.
class AccountDeletionService {
  const AccountDeletionService(this._client);

  final SupabaseClient? _client;

  /// Deletes the authenticated user's GymLvl account and associated data.
  ///
  /// Public/user-owned data is deleted first via the owner-scoped
  /// `delete_account_data` RPC, then the Supabase Auth user row is removed
  /// using the operator-owned service_role key (server-side only).
  ///
  /// There is no distributed transaction across PostgreSQL and Auth, so the
  /// result distinguishes full success (200) from deferred Auth removal
  /// (202). A deferred result is retry-safe: public data is already deleted
  /// and retrying only attempts Auth removal again.
  Future<AccountDeletionOutcome> deleteAccount() async {
    try {
      final response = await _client!.functions.invoke(
        'delete-account',
        method: HttpMethod.post,
      );

      final data = response.data as Map<String, dynamic>?;
      final code = data?['code'] as String?;

      switch (code) {
        case 'account_deleted':
          return const AccountDeletionOutcome(AccountDeletionResult.success);
        case 'auth_row_removal_deferred':
          return const AccountDeletionOutcome(AccountDeletionResult.deferred);
        case 'deletion_failed':
        case 'unauthorized':
        case 'service_unavailable':
        default:
          return AccountDeletionOutcome(
            AccountDeletionResult.failed,
            message: data?['error'] as String?,
          );
      }
    } on Exception catch (_) {
      return const AccountDeletionOutcome(AccountDeletionResult.failed);
    }
  }
}
