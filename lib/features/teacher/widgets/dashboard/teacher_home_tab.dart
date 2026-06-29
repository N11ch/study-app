import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/auth_state.dart';
import '../../../../core/services/booking_api_service.dart';
import '../../../../core/services/tutor_api_service.dart';
import '../../../../core/services/user_api_service.dart';
import 'teacher_courses_tab.dart';

class TeacherHomeTab extends StatefulWidget {
  const TeacherHomeTab({super.key});

  @override
  State<TeacherHomeTab> createState() => _TeacherHomeTabState();
}

class _TeacherHomeTabState extends State<TeacherHomeTab> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _bookings = [];



  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await BookingApiService.instance.getTutorBookings();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _bookings = result.bookings ?? [];
      } else {
        _error = result.errorMessage;
      }
    });
  }

  Future<void> _handleConfirm(String bookingId) async {
    setState(() => _loading = true);
    final res = await BookingApiService.instance.confirmBooking(bookingId);
    if (!mounted) return;
    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed successfully!'), backgroundColor: Color(0xFF10B981)),
      );
      _loadData();
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.errorMessage ?? 'Failed to confirm booking.')),
      );
    }
  }

  Future<void> _handleDecline(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Booking?'),
        content: const Text('Are you sure you want to decline this booking request? The student will be refunded.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Decline')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      final res = await BookingApiService.instance.declineBooking(bookingId);
      if (!mounted) return;
      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking declined successfully.'), backgroundColor: Color(0xFFEF4444)),
        );
        _loadData();
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.errorMessage ?? 'Failed to decline booking.')),
        );
      }
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

  void _showCreateOfferDialog() {
    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    final coinsController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    bool isCreating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create New Session Offer',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Offer Title',
                      hintText: 'e.g., Master Flutter Basics',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: summaryController,
                    decoration: InputDecoration(
                      labelText: 'Summary / Description',
                      hintText: 'Brief explanation of what you will cover',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: coinsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Coins Per Hour',
                            hintText: 'e.g., 150',
                            prefixIcon: const Icon(Icons.toll_rounded, color: Colors.amber),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Duration (Minutes)',
                            hintText: 'e.g., 60',
                            prefixIcon: const Icon(Icons.timer_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isCreating
                        ? null
                        : () async {
                            final title = titleController.text.trim();
                            final coinsText = coinsController.text.trim();
                            final durationText = durationController.text.trim();

                            if (title.isEmpty || coinsText.isEmpty || durationText.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill in all fields.')),
                              );
                              return;
                            }

                            final coins = int.tryParse(coinsText);
                            final duration = int.tryParse(durationText);
                            if (coins == null || coins <= 0 || duration == null || duration <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter valid numbers.')),
                              );
                              return;
                            }

                            setModalState(() => isCreating = true);
                            final res = await TutorApiService.instance.createOffer(
                              title: title,
                              summary: summaryController.text.trim(),
                              coinsPerHour: coins,
                              durationMinutes: duration,
                            );

                            if (context.mounted) {
                              setModalState(() => isCreating = false);
                              if (res.success) {
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(context);
                                _loadData();
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const TeacherCoursesTab()),
                                );
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Session offer created successfully!'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res.errorMessage ?? 'Failed to create offer.')),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Create Offer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthState.instance.displayName;

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
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(name),
                  const SizedBox(height: 20),
                  _buildCreateOfferBanner(),
                  const SizedBox(height: 28),
                  _buildUpcomingSessions(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning! 👋',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              ListenableBuilder(
                listenable: AuthState.instance,
                builder: (context, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.toll_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${AuthState.instance.coinsBalance}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: AuthState.instance.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          AuthState.instance.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                        ),
                      )
                    : const Icon(Icons.person_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateOfferBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ready to tutor?',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create a new session offer to start receiving bookings!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateOfferDialog,
                    icon: const Icon(Icons.add_rounded, color: Color(0xFF1E40AF), size: 18),
                    label: const Text(
                      'Create Offer',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.menu_book_rounded, color: Colors.white24, size: 72),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          )
        else if (_bookings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No upcoming sessions.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          )
        else
          ..._bookings.take(3).map(_buildBookingCard),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status']?.toString() ?? '';
    final startAt = booking['start_at']?.toString() ?? '';
    final title = (booking['tutor_offer'] as Map<String, dynamic>?)?['title']?.toString() ??
        booking['description']?.toString() ??
        'Session';

    DateTime? parsedTime;
    try {
      parsedTime = DateTime.parse(startAt);
    } catch (_) {}
    final timeLabel = parsedTime != null
        ? '${parsedTime.hour}:${parsedTime.minute.toString().padLeft(2, '0')}'
        : startAt;

    return _buildSessionCard({
      'id': booking['id'],
      'title': title,
      'time': timeLabel,
      'students': 1,
      'status': status,
    });
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final status = (session['status']?.toString() ?? '').toUpperCase();
    final isPending = status == 'PENDING';
    final isConfirmed = status == 'CONFIRMED';
    final String bookingId = session['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.videocam_rounded, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['title'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          session['time'] as String,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPending 
                      ? const Color(0xFFFEF2F2) 
                      : isConfirmed 
                          ? const Color(0xFFD1FAE5) 
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPending 
                        ? const Color(0xFFEF4444) 
                        : isConfirmed 
                            ? const Color(0xFF10B981) 
                            : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          if (isPending || isConfirmed) ...[
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending) ...[
                  TextButton(
                    onPressed: () => _handleDecline(bookingId),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Decline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _handleConfirm(bookingId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ] else if (isConfirmed) ...[
                  ElevatedButton.icon(
                    onPressed: () => _handleJoin(bookingId),
                    icon: const Icon(Icons.videocam_rounded, size: 16),
                    label: const Text('Join Class', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }


}
