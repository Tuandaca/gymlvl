import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../ui/widgets/system_button.dart';
import '../../../../ui/widgets/system_panel.dart';
import '../../../../ui/widgets/system_text_field.dart';
import '../providers/auth_providers.dart';

class AuthFormScreen extends ConsumerStatefulWidget {
  const AuthFormScreen({super.key, required this.register});
  final bool register;

  @override
  ConsumerState<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends ConsumerState<AuthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  String? _notice;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  bool get _validEmail =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim());

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isLoading ||
        !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _notice = null);
    final controller = ref.read(authControllerProvider.notifier);
    if (widget.register) {
      await controller.signUp(_email.text.trim(), _password.text);
    } else {
      await controller.signIn(_email.text.trim(), _password.text);
    }
    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      setState(
        () => _notice = widget.register ? 'register_failed' : 'auth_failed',
      );
    } else if (widget.register &&
        ref.read(authRepositoryProvider).currentUser == null) {
      setState(() => _notice = 'check_email');
    }
  }

  Future<void> _resetPassword() async {
    if (!_validEmail) {
      setState(() => _notice = 'invalid_email');
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .resetPassword(_email.text.trim());
    if (!mounted) return;
    setState(
      () => _notice = ref.read(authControllerProvider).hasError
          ? 'request_failed'
          : 'reset_email_sent',
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading;
    final language = ref.watch(localizationModeProvider);
    final title = (widget.register ? 'register' : 'login').tr(ref);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: SegmentedButton<AppLangMode>(
                      segments: const [
                        ButtonSegment(value: AppLangMode.vi, label: Text('VI')),
                        ButtonSegment(value: AppLangMode.en, label: Text('EN')),
                      ],
                      selected: {
                        language == AppLangMode.en
                            ? AppLangMode.en
                            : AppLangMode.vi,
                      },
                      onSelectionChanged: (value) => ref
                          .read(localizationModeProvider.notifier)
                          .setMode(value.first),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Icon(
                    Icons.bolt_rounded,
                    color: AppTheme.cyanNeon,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'GYMLEVEL',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(letterSpacing: 3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'auth_intro'.tr(ref),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SystemPanel(
                    glow: false,
                    padding: const EdgeInsets.all(24),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 24),
                            SystemTextField(
                              controller: _email,
                              hintText: 'auth_email'.tr(ref),
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              validator: (_) =>
                                  _validEmail ? null : 'invalid_email'.tr(ref),
                            ),
                            const SizedBox(height: 18),
                            SystemTextField(
                              controller: _password,
                              hintText: 'auth_password'.tr(ref),
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              autofillHints: [
                                widget.register
                                    ? AutofillHints.newPassword
                                    : AutofillHints.password,
                              ],
                              textInputAction: widget.register
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              onSubmitted: (_) {
                                if (!widget.register) _submit();
                              },
                              validator: (value) => (value ?? '').isEmpty
                                  ? 'password_required'.tr(ref)
                                  : widget.register && value!.length < 8
                                  ? 'password_min'.tr(ref)
                                  : null,
                            ),
                            if (widget.register) ...[
                              const SizedBox(height: 18),
                              SystemTextField(
                                controller: _confirmation,
                                hintText: 'auth_confirm_password'.tr(ref),
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                validator: (value) => value == _password.text
                                    ? null
                                    : 'password_mismatch'.tr(ref),
                              ),
                            ] else
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: loading ? null : _resetPassword,
                                  child: Text('forgot_password'.tr(ref)),
                                ),
                              ),
                            if (_notice != null) ...[
                              const SizedBox(height: 16),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  _notice!.tr(ref),
                                  style: const TextStyle(
                                    color: AppTheme.textMain,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SystemButton(
                              text: title,
                              isLoading: loading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        (widget.register ? 'already_registered' : 'new_player')
                            .tr(ref),
                        style: const TextStyle(color: AppTheme.textDim),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () => context.go(
                                widget.register ? '/login' : '/register',
                              ),
                        child: Text(
                          (widget.register ? 'login' : 'register').tr(ref),
                        ),
                      ),
                    ],
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
