import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_engine.dart';
import '../providers/auth_providers.dart';

class SessionGateScreen extends ConsumerWidget {
  const SessionGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateStreamProvider);
    final user = ref.watch(currentUserProvider);
    final failed = auth.hasError || user.hasError;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!failed) const CircularProgressIndicator(),
                  if (failed) const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 24),
                  Text(
                    translateText(
                      ref,
                      vi: failed
                          ? 'Chưa thể tải hồ sơ. Hãy kiểm tra kết nối và thử lại.'
                          : 'Đang khôi phục phiên đăng nhập…',
                      en: failed
                          ? 'Your profile could not load. Check your connection and try again.'
                          : 'Restoring your session…',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (failed) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(authStateStreamProvider);
                        ref.invalidate(currentUserProvider);
                        ref.invalidate(currentUserProfileProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        translateText(ref, vi: 'Thử lại', en: 'Retry'),
                      ),
                    ),
                    TextButton(
                      onPressed: ref.watch(authControllerProvider).isLoading
                          ? null
                          : () => ref
                                .read(authControllerProvider.notifier)
                                .signOut(),
                      child: Text('logout'.tr(ref)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
