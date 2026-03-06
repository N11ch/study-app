import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/social_auth_button.dart';
import '../../../core/widgets/inputs/text_input.dart';
import '../../../core/widgets/inputs/password_text_field.dart';
import '../../../core/constants/app_assets.dart';

/// Modern login screen with theme-aware styling
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate login
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacementNamed('/student-dashboard');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xl),
                
                // Header
                Text(
                  'Welcome Back',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: AppSizes.sm),
                
                Text(
                  'Sign in to continue your learning journey',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: AppSizes.xxl),
                
                // Email Input
                TextInput(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSizes.md),
                
                // Password Input
                PasswordTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  hint: 'Enter your password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSizes.lg),
                
                // Login Button
                PrimaryButton(
                  text: AppStrings.login,
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: AppSizes.xl),
                
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: Text(
                        'Or continue with',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSizes.xl),
                
                // Social Login Buttons
                Column(
                  children: [
                    SocialAuthButton(
                      label: 'Continue with Google',
                      icon: Image.asset(AppAssets.googleIcon),
                      onPressed: () {}, onApplePressed: () {  }, onGooglePressed: () {  }, googleButtonText: '', appleButtonText: '',
                    ),
                    const SizedBox(height: AppSizes.md),
                    SocialAuthButton(
                      label: 'Continue with Apple',
                      icon: Image.asset(AppAssets.appleIcon),
                      onPressed: () {}, onApplePressed: () {  }, onGooglePressed: () {  }, googleButtonText: '', appleButtonText: '',
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSizes.xxl),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: Text(
                        AppStrings.register,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
