import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/auth_state.dart';
import '../../../../core/services/user_api_service.dart';
import '../../../student/screens/chat_detail.screen.dart';

class TeacherMessageTab extends StatefulWidget {
  const TeacherMessageTab({super.key});

  @override
  State<TeacherMessageTab> createState() => _TeacherMessageTabState();
}

class _TeacherMessageTabState extends State<TeacherMessageTab> {
  List<ChatThread> _threads = [];
  List<ChatThread> _filtered = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _load(isInitial: true);
    _searchController.addListener(_onSearch);
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    _searchController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _load(isInitial: false);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _load({bool isInitial = false}) async {
    if (isInitial) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final result = await UserApiService.instance.getChatThreadList();
    if (!mounted) return;

    if (result.success) {
      final newThreads = result.threads ?? [];

      bool hasChanged = newThreads.length != _threads.length;
      if (!hasChanged && newThreads.isNotEmpty && _threads.isNotEmpty) {
        for (int i = 0; i < newThreads.length; i++) {
          if (newThreads[i].lastMessage.id != _threads[i].lastMessage.id ||
              newThreads[i].unreadCount != _threads[i].unreadCount) {
            hasChanged = true;
            break;
          }
        }
      }

      if (hasChanged || isInitial) {
        setState(() {
          _isLoading = false;
          _threads = newThreads;
          _onSearch();
        });
      }
    } else if (isInitial) {
      setState(() {
        _isLoading = false;
        _error = result.errorMessage;
      });
    }
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _threads
          .where((t) => t.partner.displayName.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'Messages',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 24),

              // Chat Thread List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _error != null
                        ? _buildError()
                        : _filtered.isEmpty
                            ? const _EmptyMessages()
                            : _buildThreadList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade400,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildThreadList() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0),
        itemCount: _filtered.length,
        itemBuilder: (context, i) => _ThreadCard(thread: _filtered[i]),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final ChatThread thread;
  const _ThreadCard({required this.thread});

  @override
  Widget build(BuildContext context) {
    final name = thread.partner.displayName;
    final trimmedName = name.trim();
    final initials = trimmedName.isEmpty
        ? '?'
        : trimmedName.split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase();
    final avatarUrl = thread.partner.avatarUrl;
    final isRead = thread.unreadCount == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE0E7FF),
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                )
              : null,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            (thread.lastMessage.fromId == AuthState.instance.userId ? 'Anda: ' : '') + thread.lastMessage.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isRead ? Colors.grey.shade500 : const Color(0xFF1E293B),
              fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(thread.lastMessage.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: isRead ? Colors.grey.shade400 : const Color(0xFF3B82F6),
              ),
            ),
            if (!isRead) ...[
              const SizedBox(height: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                otherId: thread.partner.id,
                otherName: thread.partner.displayName,
                otherAvatarUrl: thread.partner.avatarUrl,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Conversations with your students\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
