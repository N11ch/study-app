import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_state.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/text_input.dart';
import '../../../core/widgets/inputs/password_text_field.dart';

/// Register screen - same design as login page
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // MOCK MODE: Toggle via AppConfig.USE_MOCK
  // REGISTER DARI BIASA METHOD
  Future<void> _register() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please agree to the Terms of Service and Privacy Policy'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (!AppConfig.USE_MOCK) {
          final response = await http.post(
            Uri.parse('${AppConfig.API_URL}/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
            }),
          );

          if (!mounted) return;
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;

          if (response.statusCode == 200 || response.statusCode == 201) {
            AuthState.instance.setFromResponse(responseData);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.of(context).pushReplacementNamed('/update-profile');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message'] ??
                    'Registration failed, try again later'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } else {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          if (mounted) setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! (Mock)'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/update-profile');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again later.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      // Future.delayed(const Duration(seconds: 1), () {
      //   if (!mounted) return;
      //   setState(() => _isLoading = false);
      //   Navigator.of(context).pushReplacementNamed('/login');
      // });
    }
  }

  // Future<void> _handleGoogleSignIn() async {
  //   if (!_acceptTerms) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content:
  //             Text('Please agree to the Terms of Service and Privacy Policy'),
  //       ),
  //     );
  //     return;
  //   }

  //   try {
  //     final GoogleSignIn googleSignInMethod = GoogleSignIn();
  //     final GoogleSignInAccount? googleUser =
  //         await googleSignInMethod.signOut();

  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final String? idToken = googleAuth.idToken;

  //     if (googleUser != null) {
  //       print(googleUser.email);
  //       Navigator.of(context).pushReplacementNamed('/student-dashboard');
  //     }
  //   } catch (error) {
  //     print("Google Sign-In Error: $error");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to sign in with Google. Please try again.'),
  //         backgroundColor: Colors.redAccent,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.info,
      body: Column(
        children: [
          // ── White card body ───────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.xl,
                  AppSizes.lg,
                  AppSizes.lg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ─────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Text(
                              AppStrings.createAccount,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.info,
                              ),
                            ),
                            Text(
                              'Sign up to start your learning journey',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.md),

                      // ── Email ─────────────────────────────────
                      _buildLabel(AppStrings.email),
                      const SizedBox(height: AppSizes.xs),
                      TextInput(
                        controller: _emailController,
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        borderColor: AppColors.info,
                        borderRadius: AppSizes.radiusFull,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (!value.contains('@')) {
                            return AppStrings.invalidEmail;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSizes.md),

                      // ── Password ──────────────────────────────
                      _buildLabel(AppStrings.password),
                      const SizedBox(height: AppSizes.xs),
                      PasswordTextField(
                        controller: _passwordController,
                        hint: 'Enter your password',
                        textInputAction: TextInputAction.next,
                        borderColor: AppColors.info,
                        borderRadius: AppSizes.radiusFull,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (value.length < 6) {
                            return AppStrings.passwordTooShort;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSizes.md),

                      // ── Confirm Password ──────────────────────
                      _buildLabel(AppStrings.confirmPassword),
                      const SizedBox(height: AppSizes.xs),
                      PasswordTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm your password',
                        textInputAction: TextInputAction.done,
                        borderColor: AppColors.info,
                        borderRadius: AppSizes.radiusFull,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (value != _passwordController.text) {
                            return AppStrings.passwordNotMatch;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSizes.xl),

                      // ── Or sign up with ───────────────────────
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: AppColors.divider)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md),
                            child: Text(
                              AppStrings.orSignUpWith,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.divider)),
                        ],
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // ── Social Buttons ────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIconButton(
                            onPressed: () {},
                            child: const _GoogleLogo(),
                          ),
                          const SizedBox(width: AppSizes.md),
                          _SocialIconButton(
                            onPressed: () {
                              // Apple SSO
                            },
                            child: const _AppleLogo(),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.lg),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: AppSizes.md),

                      // ── Terms Checkbox ────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (v) =>
                                  setState(() => _acceptTerms = v ?? false),
                              activeColor: AppColors.info,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: AppStrings.termsOfService,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: AppStrings.privacyPolicy,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.xl),

                      // ── Register Button ───────────────────────
                      PrimaryButton(
                        text: AppStrings.register,
                        onPressed: _acceptTerms ? _register : null,
                        isLoading: _isLoading,
                        radius: AppSizes.radiusFull,
                        size: ButtonSize.large,
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // ── Login Link ────────────────────────────
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(text: '${AppStrings.haveAccount} '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .pushReplacementNamed('/login'),
                                  child: Text(
                                    AppStrings.signIn,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.info,
      ),
    );
  }
}

// ── Google Logo ───────────────────────────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const FaIcon(
      FontAwesomeIcons.google,
      size: 26,
      color: Color(0xFF4285F4),
    );
  }
}

// ── Apple Logo ────────────────────────────────────────────────────────────────

class _AppleLogo extends StatelessWidget {
  const _AppleLogo();

  @override
  Widget build(BuildContext context) {
    return const FaIcon(
      FontAwesomeIcons.apple,
      size: 28,
      color: Colors.black,
    );
  }
}

// - Social Icon Button ────────────────────────────────────────────────────────

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: AppColors.info, width: 1.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}
