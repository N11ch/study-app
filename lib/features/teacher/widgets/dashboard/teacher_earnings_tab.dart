import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/auth_state.dart';
import '../../../../core/services/coin_service.dart';
import '../../../../core/services/tutor_api_service.dart';

class TeacherEarningsTab extends StatefulWidget {
  const TeacherEarningsTab({super.key});

  @override
  State<TeacherEarningsTab> createState() => _TeacherEarningsTabState();
}

class _TeacherEarningsTabState extends State<TeacherEarningsTab> {
  bool _loading = true;
  String? _error;
  int _balance = 0;
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _withdrawals = [];

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

    final balanceFuture = CoinService.instance.getCoinBalance();
    final historyFuture = CoinService.instance.getCoinHistory();
    final withdrawalFuture = TutorApiService.instance.getWithdrawalHistory();

    final balanceRes = await balanceFuture;
    final historyRes = await historyFuture;
    final withdrawalRes = await withdrawalFuture;

    if (!mounted) return;

    setState(() {
      _loading = false;
      _balance = balanceRes.balance ?? AuthState.instance.coinsBalance;
      _history = historyRes.history ?? [];
      _withdrawals = withdrawalRes.withdrawals ?? [];
      if (!balanceRes.success && !historyRes.success) {
        _error = balanceRes.errorMessage ?? historyRes.errorMessage;
      }
    });
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController(text: _balance.toString());
    final accountNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final bankNameController = TextEditingController(text: 'BCA');
    String paymentMethod = 'Bank Transfer';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Request Withdrawal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Coins Amount',
                    prefixIcon: Icon(Icons.toll_rounded, color: Colors.amber),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'E-Wallet', child: Text('E-Wallet')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        paymentMethod = val;
                        if (val == 'E-Wallet') {
                          bankNameController.text = 'GOPAY';
                        } else {
                          bankNameController.text = 'BCA';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankNameController,
                  decoration: InputDecoration(
                    labelText: paymentMethod == 'Bank Transfer' ? 'Bank Name' : 'E-Wallet Provider',
                    hintText: paymentMethod == 'Bank Transfer' ? 'e.g., BCA, Mandiri' : 'e.g., GOPAY, OVO',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Account / Phone Number',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountNameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final amountText = amountController.text.trim();
                      final accountName = accountNameController.text.trim();
                      final accountNumber = accountNumberController.text.trim();
                      final bankName = bankNameController.text.trim();

                      if (amountText.isEmpty || accountName.isEmpty || accountNumber.isEmpty || bankName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all fields.')),
                        );
                        return;
                      }

                      final amount = int.tryParse(amountText);
                      if (amount == null || amount <= 0 || amount > _balance) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid amount within your balance.')),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      final res = await TutorApiService.instance.requestWithdrawal(
                        coinsAmount: amount,
                        accountName: accountName,
                        accountNumber: accountNumber,
                        paymentMethod: paymentMethod,
                        bankName: bankName,
                      );

                      if (context.mounted) {
                        setDialogState(() => isSubmitting = false);
                        if (res.success) {
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Withdrawal request submitted successfully!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res.errorMessage ?? 'Failed to submit request.')),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  int get _thisMonthEarned {
    final now = DateTime.now();
    return _history
        .where((t) {
          final dt = DateTime.tryParse(t['created_at']?.toString() ?? '');
          return dt != null &&
              dt.month == now.month &&
              dt.year == now.year &&
              (t['kind']?.toString() ?? '').toUpperCase().contains('EARN');
        })
        .fold<int>(0, (sum, t) => sum + ((t['amount'] as num?)?.toInt() ?? 0));
  }

  int get _pendingWithdrawalCoins {
    return _withdrawals
        .where((w) => w['status']?.toString() == 'PENDING')
        .fold<int>(0, (sum, w) => sum + ((w['coins_amount'] as num?)?.toInt() ?? 0));
  }

  List<Map<String, dynamic>> get _mergedTransactions {
    final all = [
      ..._history.map((t) => {...t, '_type': 'coin'}),
      ..._withdrawals.map((w) => {...w, '_type': 'withdrawal'}),
    ];
    all.sort((a, b) {
      final da = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });
    return all.take(20).toList();
  }

  String _monthName(int month) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][month];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                100.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Earnings',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                Container(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E40AF).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Balance',
                              style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: AppSizes.xs),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$_balance coins',
                                  style: textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _balance > 0 ? _showWithdrawDialog : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E40AF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('This Month',
                                          style: textTheme.bodySmall
                                              ?.copyWith(color: Colors.white70)),
                                      Text('$_thisMonthEarned coins',
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          )),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pending Withdrawal',
                                          style: textTheme.bodySmall
                                              ?.copyWith(color: Colors.white70)),
                                      Text('$_pendingWithdrawalCoins coins',
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Recent Transactions',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red))
                else if (_mergedTransactions.isEmpty)
                  const Text('No transactions yet.',
                      style: TextStyle(color: Color(0xFF64748B)))
                else
                  ..._mergedTransactions.map(_buildTransactionItem),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final textTheme = Theme.of(context).textTheme;
    final type = tx['_type']?.toString() ?? 'coin';
    final isWithdrawal = type == 'withdrawal';
    final isIncome = !isWithdrawal &&
        (tx['kind']?.toString() ?? '').toUpperCase().contains('EARN');

    final label = isWithdrawal
        ? 'Withdrawal'
        : (tx['note']?.toString() ??
            tx['kind']?.toString() ??
            'Transaction');
    final amount = (tx['amount'] as num?)?.toInt() ??
        (tx['coins_amount'] as num?)?.toInt() ??
        0;
    final dateStr = tx['created_at']?.toString() ?? '';
    final dt = DateTime.tryParse(dateStr);
    final dateLabel = dt != null
        ? '${_monthName(dt.month)} ${dt.day}, ${dt.year}'
        : dateStr;

    final showPositive = isIncome && !isWithdrawal;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: showPositive
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              showPositive ? Icons.arrow_downward : Icons.arrow_upward,
              size: 22,
              color: showPositive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '${showPositive ? '+' : '-'}$amount coins',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: showPositive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}
