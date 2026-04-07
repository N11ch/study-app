import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_state.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/inputs/search_input.dart';
import '../../../core/widgets/common/empty_state.dart';
import '../../../data/dummy_data.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1565C0), Color(0xFFD6E8FF)],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient — guaranteed to fill the entire screen
          Positioned.fill(
            child: DecoratedBox(decoration: const BoxDecoration(gradient: _gradient)),
          ),
          // Tab content
          IndexedStack(
            index: _currentIndex,
            children: const [
              _HomeTab(),
              Center(child: Text(AppStrings.schedule, style: TextStyle(color: Colors.white))),
              Center(child: Text(AppStrings.myLearning, style: TextStyle(color: Colors.white))),
              Center(child: Text(AppStrings.profile, style: TextStyle(color: Colors.white))),
            ],
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : AppColors.textDisabled),
          if (!isSelected)
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    if (DummyData.teachers.isEmpty) {
      return const EmptyState(message: 'No tutors available');
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(context),
        _buildSectionLabel('Search Tutor by Topic >'),
        _buildTopicsGrid(),
        _buildSectionLabel('Top Rated Tutor >'),
        _buildTutorList(context),
        const SizedBox(height: 110),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final displayName = AuthState.instance.displayName;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg, AppSizes.lg, AppSizes.lg, AppSizes.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: AppTypography.subtitle(context).copyWith(color: Colors.white70),
            ),
            Text(
              displayName,
              style: AppTypography.headline(context).copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SearchInput(hint: 'Search tutor...'),
                  const Divider(height: 32),
                  _buildUpcomingDetail(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDetail(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Session',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                'Dr. Amba Rusdi, S.Kom.',
                style: AppTypography.title(context).copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        // Constrained Join button — avoids PrimaryButton's full-width SizedBox
        SizedBox(
          width: 64,
          height: 36,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Join', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1A237E), // dark navy — readable on the light-blue lower gradient
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
      ),
      itemCount: 8,
      itemBuilder: (context, i) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: const Icon(Icons.book, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          const Text('Topic', style: TextStyle(color: Color(0xFF1A237E), fontSize: 10)),
        ],
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

  Widget _buildTutorList(BuildContext context) {
    final teachers = DummyData.teachers;
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        itemCount: teachers.length,
        itemBuilder: (context, i) {
          final teacher = teachers[i];
          final expertise = teacher.expertise.isNotEmpty ? teacher.expertise.first : '';
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(expertise, style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
              ],
            ),
          );
        },
      ),
    );
  }
}
