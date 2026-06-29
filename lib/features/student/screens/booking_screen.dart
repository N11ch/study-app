import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/auth_state.dart';
import '../../../core/services/booking_api_service.dart';
import '../../../core/services/coin_service.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/outline_button.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../routes/app_routes.dart';

class BookingScreen extends StatefulWidget {
  final String tutorId;
  final String tutorName;
  final Map<String, dynamic> offer;

  const BookingScreen({
    super.key,
    required this.tutorId,
    required this.tutorName,
    required this.offer,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDateTime;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await BookingApiService.instance.createBooking(
      tutorId: widget.tutorId,
      tutorOfferId: widget.offer['id'],
      startAt: _selectedDateTime!.toUtc().toIso8601String(),
      notes: _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      // Refresh coin balance after successful booking
      CoinService.instance.getCoinBalance();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Booking Requested!'),
          content: const Text('Your request has been sent to the tutor. You will be notified once they confirm.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // dialog
                Navigator.of(context).pop(); // booking screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Failed to create booking.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinsCost = int.tryParse(widget.offer['coins_per_hour']?.toString() ?? '0') ?? 0;
    final duration = int.tryParse(widget.offer['duration_minutes']?.toString() ?? '60') ?? 60;

    final studentCoins = AuthState.instance.coinsBalance;
    final hasEnoughCoins = studentCoins >= coinsCost;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book Session'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
            _buildSummary(coinsCost, duration),
            const SizedBox(height: AppSizes.lg),

            Text('Select Schedule', style: AppTypography.title(context)),
            const SizedBox(height: AppSizes.md),
            
            _buildDateTimePicker(),

            const SizedBox(height: AppSizes.lg),
            Text('Notes for Tutor (Optional)', style: AppTypography.title(context)),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any specific topics you want to cover?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            if (!hasEnoughCoins) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Insufficient coins. You have $studentCoins coins, but this session requires $coinsCost coins.',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              OutlineButton(
                text: 'Top Up Coins',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.coinPurchase),
                borderColor: AppColors.primary,
                textColor: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.lg),
            ],
            PrimaryButton(
              text: 'Confirm Booking',
              onPressed: hasEnoughCoins ? _submit : null,
              isLoading: _isSubmitting,
              backgroundColor: hasEnoughCoins ? AppColors.primary : Colors.grey.shade300,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return GestureDetector(
      onTap: _pickDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 16),
        decoration: BoxDecoration(
          color: _selectedDateTime != null ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: _selectedDateTime != null ? AppColors.primary : AppColors.divider,
            width: _selectedDateTime != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded, 
              color: _selectedDateTime != null ? AppColors.primary : AppColors.textTertiary
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDateTime != null 
                  ? DateFormat('EEEE, d MMM yyyy · HH:mm').format(_selectedDateTime!)
                  : 'Choose date and time',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: _selectedDateTime != null ? FontWeight.w700 : FontWeight.w500,
                  color: _selectedDateTime != null ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(int coins, int minutes) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(widget.offer['title'] ?? 'Session',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text('with ${widget.tutorName}', style: const TextStyle(color: AppColors.textSecondary)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryItem(Icons.access_time, '$minutes min'),
              _summaryItem(Icons.toll_rounded, '$coins coins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
