import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/booking_api_service.dart';
import '../../../../core/services/user_api_service.dart';

class TeacherScheduleTab extends StatefulWidget {
  const TeacherScheduleTab({super.key});

  @override
  State<TeacherScheduleTab> createState() => _TeacherScheduleTabState();
}

class _TeacherScheduleTabState extends State<TeacherScheduleTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _error;

  static const _tabs = ['Pending', 'Upcoming', 'History'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await BookingApiService.instance.getTutorBookings();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.success) {
        final all = result.bookings ?? [];
        _pending = all.where((b) => b['status']?.toString().toUpperCase() == 'PENDING').toList()
          ..sort((a, b) => (a['start_at']?.toString() ?? '').compareTo(b['start_at']?.toString() ?? ''));
        
        _upcoming = all.where((b) => b['status']?.toString().toUpperCase() == 'CONFIRMED').toList()
          ..sort((a, b) => (a['start_at']?.toString() ?? '').compareTo(b['start_at']?.toString() ?? ''));

        _history = all.where((b) {
          final s = b['status']?.toString().toUpperCase() ?? '';
          return s == 'COMPLETED' || s == 'CANCELLED' || s == 'DECLINED';
        }).toList()
          ..sort((a, b) => (b['start_at']?.toString() ?? '').compareTo(a['start_at']?.toString() ?? ''));
      } else {
        _error = result.errorMessage;
      }
    });
  }

  Future<void> _handleConfirm(String id) async {
    final res = await BookingApiService.instance.confirmBooking(id);
    if (!mounted) return;
    if (res.success) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session confirmed successfully!'), backgroundColor: Color(0xFF10B981)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.errorMessage ?? 'Failed to confirm booking.')),
      );
    }
  }

  Future<void> _handleDecline(String id) async {
    final res = await BookingApiService.instance.declineBooking(id);
    if (!mounted) return;
    if (res.success) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session declined.'), backgroundColor: Color(0xFFEF4444)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.errorMessage ?? 'Failed to decline booking.')),
      );
    }
  }

  Future<void> _handleJoin(String bookingId) async {
    final result = await UserApiService.instance.getJoinInfo(bookingId);
    if (!mounted) return;
    if (result.success && result.meetingUrl != null) {
      final uri = Uri.parse(result.meetingUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open meeting URL')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorMessage ?? 'Cannot join session yet')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF93C5FD),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'My Schedule',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tab Bar Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: const Color(0xFF1E3A8A),
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    dividerColor: Colors.transparent,
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tab Views
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _error != null
                        ? _buildError()
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildList(_pending, 'pending'),
                              _buildList(_upcoming, 'upcoming'),
                              _buildList(_history, 'history'),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white70),
          const SizedBox(height: AppSizes.md),
          Text(_error!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: AppSizes.md),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, String listType) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event_busy_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'No $listType sessions found',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 120.0),
        itemCount: items.length,
        itemBuilder: (context, i) => _buildCard(items[i], listType),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> b, String listType) {
    final id = b['id']?.toString() ?? '';
    final status = b['status']?.toString().toUpperCase() ?? '';
    final startAt = b['start_at']?.toString() ?? '';
    final student = b['student'] as Map<String, dynamic>? ?? {};
    final studentName = student['full_name']?.toString() ?? student['username']?.toString() ?? 'Student';
    final duration = b['duration_minutes']?.toString() ?? '60';

    final offer = b['tutor_offer'] as Map<String, dynamic>? ?? {};
    final title = offer['title']?.toString() ?? b['description']?.toString() ?? 'Session';

    DateTime? parsedTime;
    try {
      parsedTime = DateTime.parse(startAt);
    } catch (_) {}

    String timeLabel = startAt;
    String dateLabel = '';
    if (parsedTime != null) {
      final hour = parsedTime.hour.toString().padLeft(2, '0');
      final minute = parsedTime.minute.toString().padLeft(2, '0');
      timeLabel = '$hour:$minute';
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dateLabel = '${parsedTime.day} ${months[parsedTime.month - 1]} ${parsedTime.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '$timeLabel (${duration}m)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (dateLabel.isNotEmpty)
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const Spacer(),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Siswa: $studentName',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (listType == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleDecline(id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleConfirm(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else if (listType == 'upcoming') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleJoin(id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Join Class', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status;

    switch (status) {
      case 'CONFIRMED':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        label = 'Confirmed';
        break;
      case 'PENDING':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Pending';
        break;
      case 'COMPLETED':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        label = 'Completed';
        break;
      case 'DECLINED':
      case 'CANCELLED':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = status == 'DECLINED' ? 'Declined' : 'Cancelled';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
