import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/dummy_data.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  static const _tabs = [
    _HomeTab(),
    _PlaceholderTab(label: AppStrings.schedule),
    _PlaceholderTab(label: AppStrings.myLearning),
    _PlaceholderTab(label: AppStrings.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // Use a solid scaffold background so the gradient container has a reference
      backgroundColor: const Color(0xFFF0F6FF),
      body: Stack(
        children: [
          // Full-screen gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1479FF), Color(0xFFD6E8FF)],
                  stops: [0.0, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Tab content
          IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, Icons.home_rounded, AppStrings.home),
          _navItem(1, Icons.calendar_today_rounded, AppStrings.schedule),
          _navItem(2, Icons.play_circle_rounded, AppStrings.myLearning),
          _navItem(3, Icons.person_rounded, AppStrings.profile),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textDisabled, size: 22),
            if (!selected)
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder tabs ────────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.background),
      ),
    );
  }
}

// ── Home tab ────────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final teachers = DummyData.teachers;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(context),
        _buildSectionLabel('Search Tutor by Topic >'),
        _buildTopicsGrid(),
        _buildSectionLabel('Top Rated Tutor >'),
        _buildTutorList(teachers),
        const SizedBox(height: 120),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg, AppSizes.lg, AppSizes.lg, AppSizes.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Morning,',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const Text(
              'Muh Daffa Dwi S.',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: AppSizes.md),
            // Search + upcoming card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search bar
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 12),
                        Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Search tutor...', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Divider(height: 28),
                  // Upcoming session
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Upcoming Session',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dr. Amba Rusdi, S.Kom.',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 14)
                                  ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      // Explicit fixed width so the button never overflows the Row
                      SizedBox(
                        width: 64,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            // Override the global minimumSize so it fits in 64 px
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Join', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section label ───────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.lg, 16, AppSizes.lg, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.background, // dark navy — readable on the gradient
        ),
      ),
    );
  }

  // ── Topics grid ─────────────────────────────────────────────────────────────
  Widget _buildTopicsGrid() {
    const topics = [
      (Icons.calculate_outlined, 'Math'),
      (Icons.code_rounded, 'Coding'),
      (Icons.language_rounded, 'Language'),
      (Icons.music_note_rounded, 'Music'),
      (Icons.science_outlined, 'Science'),
      (Icons.brush_rounded, 'Art'),
      (Icons.history_edu_rounded, 'History'),
      (Icons.fitness_center_rounded, 'PE'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: topics.length,
      itemBuilder: (_, i) {
        final (icon, label) = topics[i];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.background,
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Tutor list ──────────────────────────────────────────────────────────────
  Widget _buildTutorList(List teachers) {
    if (teachers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.lg),
        child: Text('No tutors available', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        itemCount: teachers.length,
        itemBuilder: (_, i) {
          final teacher = teachers[i];
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  teacher.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  teacher.expertise.isNotEmpty ? teacher.expertise.first : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      teacher.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
