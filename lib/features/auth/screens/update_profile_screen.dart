import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/auth_state.dart';
import '../../../core/services/user_api_service.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/text_input.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  /// UI + persisted for unused API path
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  /// Retained only for unused `_updateProfile` API code (not shown in UI).
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  String selectedRole = 'student';
  String _selectedRole = 'STUDENT';

  bool _isLoading = false;

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && mounted) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() => dobController.text = '$y-$m-$d');
    }
  }

  // MOCK MODE: Toggle via AppConfig.USE_MOCK
  // ignore: unused_element — preserved for backend; UI uses [_submitCompleteIdentity].
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (!AppConfig.USE_MOCK) {
      final result = await UserApiService.instance.updateProfile(
        username: _usernameController.text.trim(),
        fullName: fullNameController.text.trim(),
        bio: _bioController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        // Sync role into AuthState so the rest of the app sees the updated role
        AuthState.instance.role = result.user?['role']?.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nice! Your profile has been updated."),
            backgroundColor: Colors.green,
          ),
        );

        final role = result.user?['role']?.toString();
        if (role == 'TUTOR') {
          Navigator.of(context).pushReplacementNamed('/teacher');
        } else {
          Navigator.of(context).pushReplacementNamed('/student');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Something went wrong.'),
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
          content: Text('Nice! Your profile has been updated. (Mock)'),
          backgroundColor: Colors.green,
        ),
      );
final role = result.user?['role']?.toString();

if (role == 'TUTOR') {
  Navigator.of(context).pushReplacementNamed('/teacher-dashboard');
} else {
  Navigator.of(context).pushReplacementNamed('/student-dashboard');
}
      } else {
        Navigator.of(context).pushReplacementNamed('/student-dashboard');
      }
    }
  }

  Future<void> _submitCompleteIdentity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed('/student-dashboard');
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.info,
      ),
    );
  }

  Widget _buildRoleChip({
    required String label,
    required String value,
  }) {
    final selected = selectedRole == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => selectedRole = value),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
              decoration: BoxDecoration(
                color: selected ? AppColors.info : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: AppColors.info,
                  width: selected ? 0 : 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.info.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: selected ? AppColors.surface : AppColors.info,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.info,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + AppSizes.md),
          Expanded(
            child: Container(
              width: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Complete Identity',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'Complete your identity to continue your journey',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.info.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        'I start as a...',
                        textAlign: TextAlign.center,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Row(
                        children: [
                          _buildRoleChip(label: 'Student', value: 'student'),
                          _buildRoleChip(label: 'Tutor', value: 'tutor'),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: AppSizes.lg),
                      _buildLabel('Full Name'),
                      const SizedBox(height: AppSizes.xs),
                      TextInput(
                        controller: fullNameController,
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        borderColor: AppColors.info,
                        borderRadius: AppSizes.radiusLg,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildLabel('Date of Birth'),
                      const SizedBox(height: AppSizes.xs),
                      TextInput(
                        controller: dobController,
                        hint: 'Enter your date of birth',
                        prefixIcon: Icons.cake_outlined,
                        suffixIcon: Icons.calendar_today_outlined,
                        onSuffixIconPressed: _pickDob,
                        readOnly: true,
                        onTap: _pickDob,
                        borderColor: AppColors.info,
                        borderRadius: AppSizes.radiusLg,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: AppSizes.xl),
                      PrimaryButton(
                        text: 'Submit',
                        onPressed: _submitCompleteIdentity,
                        isLoading: _isLoading,
                        radius: AppSizes.radiusFull,
                        size: ButtonSize.large,
                        backgroundColor: AppColors.info,
                      ),
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
}
