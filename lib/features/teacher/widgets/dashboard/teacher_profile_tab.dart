import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/auth_state.dart';
import 'teacher_courses_tab.dart';
import 'teacher_earnings_tab.dart';

class TeacherProfileTab extends StatelessWidget {
  const TeacherProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We removed the solid backgroundColor here
      body: Container(
        // Applied the requested 3-color linear gradient to the entire screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B82F6), // Vivid blue at top
              Color(0xFF93C5FD), // Light blue in middle
              Color(0xFFFFFFFF), // White at bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _TeacherProfileHeader(),
            const SizedBox(height: 24),
             _buildSectionCard(
              children: [
                _ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () => Navigator.of(context).pushNamed('/update-profile'),
                ),
                _ProfileMenuItem(
                  icon: Icons.book_outlined,
                  label: 'My Offers',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TeacherCoursesTab()),
                  ),
                ),
                _ProfileMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Earnings',
                  showDivider: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TeacherEarningsTab()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              children: [
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Log Out',
                  iconColor: Colors.redAccent,
                  labelColor: Colors.redAccent,
                  showDivider: false,
                  onTap: () {
                    AuthService.instance.logout();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ],
            ),
            const SizedBox(height: 110), 
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06), // Slightly increased shadow for contrast against white
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _TeacherProfileHeader extends StatelessWidget {
  const _TeacherProfileHeader();

  @override
  Widget build(BuildContext context) {
    final name = AuthState.instance.displayName;
    final avatarUrl = AuthState.instance.avatarUrl;
    final coinsBalance = AuthState.instance.coinsBalance;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 16),
        child: Column(
          children: [
            // Avatar Profile Picture
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
                ],
              ),
              child: avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        width: 96,
                        height: 96,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person_rounded, size: 52, color: Colors.white),
                      ),
                    )
                  : const Icon(Icons.person_rounded, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 14),
            // Profile Name
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // Profile Role / Subtitle
            const Text(
              'Tutor',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            // Coin Balance Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.toll_rounded, color: Color(0xFFFFD700), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '$coinsBalance coins',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'balance',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu Item ───────────────────────────────────────────────────────────────

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool showDivider;
  final bool disabled;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.showDivider = true,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = disabled
        ? Colors.grey.shade400
        : (iconColor ?? const Color(0xFF6366F1)); 
    final effectiveLabelColor = disabled
        ? Colors.grey.shade400
        : (labelColor ?? const Color(0xFF1E293B)); 

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: effectiveIconColor, size: 20),
                ),
                const SizedBox(width: 14),
                // Label Text
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: effectiveLabelColor,
                    ),
                  ),
                ),
                // Trailing Widget ("Soon" badge or Chevron)
                if (disabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Soon',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        // Bottom Divider
        if (showDivider)
          const Divider(
            height: 1, 
            indent: 74, 
            endIndent: 20, 
            color: Color(0xFFF1F5F9), 
          ),
      ],
    );
  }
}