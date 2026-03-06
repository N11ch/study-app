
// This Dart file defines the `TestWidget`, a dedicated screen for visually
// testing and showcasing the application's reusable core UI components. It
// serves as a "widget catalog" or "style guide," allowing developers to see
// all the standard UI elements in one place, ensuring consistency and
// facilitating rapid development.
//
// The widget is stateful to demonstrate the interactive behavior of components
// like text fields, checkboxes, and selectable cards.
//
// The screen is organized into logical sections, each displaying a category of
// widgets:
//
// - **Buttons**: `PrimaryButton`, `OutlineButton`, `SocialAuthButton`.
// - **Common Widgets**: `AppLogoWidget`, `AvatarWidget`, `EmptyState`, `LoadingWidget`.
// - **Cards**: `RoleSelectionCard`.
// - **Inputs**: `TextInput`, `PasswordTextField`, `SearchInput`.
// - **Feedback**: `CustomCheckbox`.
//
// Overall, this `TestWidget` is a crucial developer tool for viewing, testing,
// and debugging the application's core UI building blocks in isolation.

import 'package:flutter/material.dart';
import 'package:myapp/core/widgets/buttons/outline_button.dart';
import 'package:myapp/core/widgets/buttons/primary_button.dart';
import 'package:myapp/core/widgets/buttons/social_auth_button.dart';
import 'package:myapp/core/widgets/common/app_logo_widget.dart';
import 'package:myapp/core/widgets/common/avatar_widget.dart';
import 'package:myapp/core/widgets/common/empty_state.dart';
import 'package:myapp/core/widgets/common/loading_widget.dart';
import 'package:myapp/core/widgets/cards/role_selection_card.dart';
import 'package:myapp/core/widgets/inputs/password_text_field.dart';
import 'package:myapp/core/widgets/inputs/search_input.dart';
import 'package:myapp/core/widgets/inputs/text_input.dart';
import 'package:myapp/core/widgets/feedback/custom_checkbox.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  // State for interactive widgets
  bool _isChecked = false;
  bool _isRoleSelected = true;
  final _textController = TextEditingController(text: 'Initial Text');
  final _passwordController = TextEditingController(text: 'password123');
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Helper to build section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Core Widgets Test Screen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === BUTTONS ===
            _buildSectionHeader('Buttons'),
            const Text('PrimaryButton:'),
            PrimaryButton(text: 'Standard', onPressed: () {}),
            const SizedBox(height: 8),
            PrimaryButton(
                text: 'Custom Color & Size',
                onPressed: () {},
                backgroundColor: Colors.amber,
                textColor: Colors.black,
                height: 60,
                width: 250),
            const SizedBox(height: 16),
            const Text('OutlineButton:'),
            OutlineButton(text: 'Standard', onPressed: () {}),
            const SizedBox(height: 8),
            OutlineButton(
                text: 'Custom Color & Width',
                onPressed: () {},
                borderColor: Colors.red,
                textColor: Colors.red,
                width: 300),
            const SizedBox(height: 16),
            const Text('SocialAuthButton:'),
            SocialAuthButton(
              onGooglePressed: () {},
              onApplePressed: () {},
              googleButtonText: 'Sign in with Google',
              appleButtonText: 'Sign in with Apple',
              label: '',
              onPressed: () {},
              icon: const Icon(Icons.apple),
            ),
            const Divider(height: 40, thickness: 1),

            // === COMMON WIDGETS ===
            _buildSectionHeader('Common Widgets'),
            const Text('AppLogoWidget:'),
            const Row(
              children: [
                AppLogoWidget(height: 80),
                SizedBox(width: 20),
                Text('Custom Size:'),
                SizedBox(width: 10),
                AppLogoWidget(height: 80, size: 80),
              ],
            ),
            const SizedBox(height: 16),
            const Text('AvatarWidget:'),
            Row(
              children: [
                const AvatarWidget(
                    imageUrl: 'https://picsum.photos/id/237/200/300',
                    radius: 30),
                const SizedBox(width: 20),
                const Text('Different radius:'),
                const SizedBox(width: 10),
                const AvatarWidget(
                    imageUrl: 'https://picsum.photos/id/238/200/300',
                    radius: 50),
              ],
            ),
            const SizedBox(height: 16),
            const Text('EmptyState:'),
            const EmptyState(
                message: 'No items found. Please try again later.',
                icon: Icons.search_off),
            const SizedBox(height: 16),
            const Text('LoadingWidget:'),
            const Row(
              children: [
                LoadingWidget(),
                SizedBox(width: 20),
                Text('Different size:'),
                SizedBox(width: 10),
                LoadingWidget(size: LoadingSize.large),
              ],
            ),
            const Divider(height: 40, thickness: 1),

            // === CARDS ===
            _buildSectionHeader('Cards'),
            const Text('RoleSelectionCard:'),
            Row(
              children: [
                Expanded(
                  child: RoleSelectionCard(
                    title: 'Student',
                    description: 'Access courses and materials.',
                    icon: Icons.school,
                    isSelected: _isRoleSelected,
                    onTap: () => setState(() => _isRoleSelected = true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RoleSelectionCard(
                    title: 'Teacher',
                    description: 'Manage courses and students.',
                    icon: Icons.work,
                    isSelected: !_isRoleSelected,
                    onTap: () => setState(() => _isRoleSelected = false),
                  ),
                ),
              ],
            ),
            const Divider(height: 40, thickness: 1),

            // === INPUTS ===
            _buildSectionHeader('Inputs'),
            const Text('TextInput:'),
            TextInput(
              controller: _textController,
              hint: 'Enter your name',
              label: 'Name',
            ),
            const SizedBox(height: 8),
            const Text('TextInput (Multiline):'),
            const TextInput(
              hint: 'Enter a long description',
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('PasswordTextField:'),
            PasswordTextField(
              controller: _passwordController,
              hint: 'Enter your password',
              label: 'Password',
            ),
            const SizedBox(height: 16),
            const Text('SearchInput:'),
            SearchInput(
              controller: _searchController,
              hint: 'Search for courses...',
              onChanged: (value) {
                // You can add search logic here
              },
            ),
            const Divider(height: 40, thickness: 1),

            // === FEEDBACK ===
            _buildSectionHeader('Feedback'),
            const Text('CustomCheckbox:'),
            CustomCheckbox(
              value: _isChecked,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _isChecked = newValue;
                  });
                }
              },
              label: 'I agree to the terms and conditions',
            ),
          ],
        ),
      ),
    );
  }
}
