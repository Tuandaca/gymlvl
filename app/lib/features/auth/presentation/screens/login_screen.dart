import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../ui/widgets/system_button.dart';
import '../../../../ui/widgets/system_panel.dart';
import '../../../../ui/widgets/system_text_field.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onLogin() async {
    // Quick validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email và Mật khẩu', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.dangerOrange),
      );
      return;
    }

    ref.read(authControllerProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cyanNeon.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
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
                            '[ SYSTEM ACTIVATED ]',
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
                            'GYMLEVEL',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              letterSpacing: 4.0,
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
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Key?', style: TextStyle(color: AppTheme.cyanNeon)),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Login Button
                        SystemButton(
                          text: 'LOGIN',
                          isLoading: isLoading,
                          onPressed: _onLogin,
                        ),
                        const SizedBox(height: 32),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR CONNECT VIA', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, letterSpacing: 1)),
                            ),
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Social Button (Placeholder)
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.white),
                          label: const Text('GOOGLE LOGIN', style: TextStyle(color: Colors.white, letterSpacing: 1)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("New Hunter?", style: TextStyle(color: AppTheme.textDim)),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text('REGISTER', style: TextStyle(color: AppTheme.cyanNeon, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
    );
  }
}
