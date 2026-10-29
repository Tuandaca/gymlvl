import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/localization_engine.dart';
import '../providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  /// The shared auth controller also carries failures from other screens
  /// (for example a rejected sign-in). Recovery must only report an error from
  /// a submit attempt made here.
  bool _submittedUpdate = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translateText(ref, vi: 'Đổi mật khẩu', en: 'Reset password'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: translateText(
                        ref,
                        vi: 'Mật khẩu mới',
                        en: 'New password',
                      ),
                    ),
                    validator: (value) => (value?.length ?? 0) < 8
                        ? translateText(
                            ref,
                            vi: 'Nhập ít nhất 8 ký tự.',
                            en: 'Use at least 8 characters.',
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmation,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: translateText(
                        ref,
                        vi: 'Nhập lại mật khẩu',
                        en: 'Confirm password',
                      ),
                    ),
                    validator: (value) => value != _password.text
                        ? translateText(
                            ref,
                            vi: 'Mật khẩu chưa khớp.',
                            en: 'Passwords do not match.',
                          )
                        : null,
                  ),
                  if (_submittedUpdate && state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        translateText(
                          ref,
                          vi: 'Không thể cập nhật. Hãy thử lại hoặc yêu cầu liên kết mới.',
                          en: 'Could not update your password. Retry or request a new recovery link.',
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            if (!_form.currentState!.validate()) return;
                            setState(() => _submittedUpdate = true);
                            await ref
                                .read(authControllerProvider.notifier)
                                .updatePassword(_password.text);
                          },
                    child: Text(
                      translateText(
                        ref,
                        vi: 'Lưu mật khẩu',
                        en: 'Save password',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
