import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../ui/widgets/system_button.dart';
import '../../../../ui/widgets/system_panel.dart';
import '../../../../ui/widgets/system_text_field.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _onRegister() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email và Mật khẩu', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.dangerOrange),
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.dangerOrange),
      );
      return;
    }

    ref.read(authControllerProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background particles/glow (Placeholder for now)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purpleNeon.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(color: AppTheme.purpleNeon.withOpacity(0.08), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.cyanNeon),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: SystemPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              Center(
                                child: Text(
                                  '[ HUNTER REGISTRATION ]',
                                  style: TextStyle(
                                    color: AppTheme.cyanNeon.withOpacity(0.8),
                                    letterSpacing: 2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'NEW PLAYER',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    letterSpacing: 4.0,
                                    fontSize: 32,
                                    shadows: [
                                      BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.5), blurRadius: 20)
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Form Fields
                              const Text('PLAYER ID', style: TextStyle(color: AppTheme.textDim, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              SystemTextField(
                                controller: _emailController,
                                hintText: 'Email address',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              
                              const Text('ACCESS KEY', style: TextStyle(color: AppTheme.textDim, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              SystemTextField(
                                controller: _passwordController,
                                hintText: 'Create password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 20),
                              
                              const Text('CONFIRM KEY', style: TextStyle(color: AppTheme.textDim, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              SystemTextField(
                                controller: _confirmController,
                                hintText: 'Retype password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 32),

                              // Register Button
                              SystemButton(
                                text: 'INITIALIZE',
                                isLoading: isLoading,
                                onPressed: _onRegister,
                              ),
                              
                              const SizedBox(height: 24),

                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Already registered?", style: TextStyle(color: AppTheme.textDim)),
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text('LOGIN', style: TextStyle(color: AppTheme.cyanNeon, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
