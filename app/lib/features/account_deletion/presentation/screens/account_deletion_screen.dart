import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/candy_colors.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_scaffold.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../account_deletion_notifier.dart';
import '../../account_deletion_service.dart';

/// Web-facing account-deletion page (/account/delete).
///
/// Reuses the same [accountDeletionNotifierProvider] as the mobile Profile
/// screen so both platforms invoke the identical backend contract. The page
/// never accepts a target user_id and can only delete the authenticated
/// caller's own account.
class AccountDeletionScreen extends ConsumerWidget {
  const AccountDeletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateStreamProvider);
    final signedIn = auth.value?.session != null;

    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          'delete_account_title'.tr(ref),
          style: const TextStyle(
            fontFamily: CandyFonts.display,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _Body(auth: auth, signedIn: signedIn, ref: ref),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final AsyncValue<AuthState> auth;
  final bool signedIn;
  final WidgetRef ref;

  const _Body({required this.auth, required this.signedIn, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!signedIn) {
      return CandyEmptyState(
        icon: Icons.login_rounded,
        title: 'delete_account_title'.tr(ref),
        message: 'account_delete_sign_in_first'.tr(ref),
        actionLabel: 'login'.tr(ref),
        onAction: () => context.push('/login'),
        actionVariant: CandyButtonVariant.primary,
      );
    }

    return switch (ref.watch(accountDeletionNotifierProvider)) {
      AsyncLoading() => const _LoadingState(),
      AsyncData(:final value) => _ResultState(outcome: value),
      AsyncError() => _ResultState(
        outcome: const AccountDeletionOutcome(AccountDeletionResult.failed),
      ),
    };
  }
}

class _LoadingState extends ConsumerWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyEmptyState(
      icon: Icons.hourglass_empty_rounded,
      title: 'delete_account_title'.tr(ref),
      message: 'account_delete_in_progress'.tr(ref),
      actionLabel: null,
    );
  }
}

class _ResultState extends ConsumerWidget {
  final AccountDeletionOutcome outcome;

  const _ResultState({required this.outcome});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (outcome.isSuccess) {
      return const _SuccessState();
    }
    if (outcome.isDeferred) {
      return const _DeferredState();
    }
    return const _FailedState();
  }
}

class _SuccessState extends ConsumerWidget {
  const _SuccessState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyEmptyState(
      icon: Icons.check_circle_rounded,
      title: 'account_deleted'.tr(ref),
      message: 'account_delete_success_desc'.tr(ref),
      actionLabel: 'login'.tr(ref),
      onAction: () async {
        final router = GoRouter.of(context);
        await SupabaseConfig.client.auth.signOut();
        router.push('/login');
      },
      actionVariant: CandyButtonVariant.primary,
    );
  }
}

class _DeferredState extends ConsumerWidget {
  const _DeferredState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyEmptyState(
      icon: Icons.hourglass_empty_rounded,
      title: 'account_delete_deferred_title'.tr(ref),
      message: 'account_delete_deferred_desc'.tr(ref),
      actionLabel: 'delete_account_confirm'.tr(ref),
      onAction: () async {
        await ref
            .read(accountDeletionNotifierProvider.notifier)
            .deleteAccount();
      },
      actionVariant: CandyButtonVariant.danger,
    );
  }
}

class _FailedState extends ConsumerWidget {
  const _FailedState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CandyEmptyState(
      icon: Icons.warning_amber_rounded,
      title: 'account_delete_failed'.tr(ref),
      message: 'account_delete_failed_desc'.tr(ref),
      actionLabel: 'delete_account_confirm'.tr(ref),
      onAction: () async {
        await ref
            .read(accountDeletionNotifierProvider.notifier)
            .deleteAccount();
      },
      actionVariant: CandyButtonVariant.danger,
    );
  }
}
