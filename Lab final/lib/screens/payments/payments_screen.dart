import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.textSecondary),
            onPressed: _showFilter,
          ),
        ],
      ),
      body: StreamBuilder<List<PaymentModel>>(
        stream: FirebaseService.getPayments(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.primaryPurple));
          }

          var payments = snap.data!;
          final total = payments.fold<double>(0, (s, p) => s + p.amount);
          final paid = payments
              .where((p) => p.status == 'paid')
              .fold<double>(0, (s, p) => s + p.amount);
          final unpaidCount = payments.where((p) => p.status != 'paid').length;

          if (_filter != 'all') {
            payments = payments.where((p) => p.status == _filter).toList();
          }
          if (_query.isNotEmpty) {
            payments = payments
                .where((p) =>
                    p.memberName.toLowerCase().contains(_query) ||
                    p.planName.toLowerCase().contains(_query))
                .toList();
          }

          return Column(
            children: [
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total Revenue',
                      value: 'PKR ${total.toInt()}',
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total Paid',
                      value: '${payments.where((p) => p.status == 'paid').length}',
                      color: AppTheme.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total Unpaid',
                      value: '$unpaidCount',
                      color: AppTheme.error,
                    ),
                  ),
                ]),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Search payments...',
                    prefixIcon:
                        Icon(Icons.search, color: AppTheme.textMuted),
                  ),
                ),
              ),
              // Filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final f in ['all', 'paid', 'unpaid', 'overdue'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: _filter == f
                                  ? AppTheme.primaryGradient
                                  : null,
                              color: _filter == f
                                  ? null
                                  : AppTheme.cardDark2,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _filter == f
                                      ? AppTheme.primaryPurple
                                      : const Color(0xFF2A2A3A)),
                            ),
                            child: Text(
                              f[0].toUpperCase() + f.substring(1),
                              style: TextStyle(
                                  color: _filter == f
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
              Expanded(
                child: payments.isEmpty
                    ? const EmptyState(
                        icon: Icons.payment_outlined,
                        title: 'No Payments',
                        subtitle: 'No payment records found')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: payments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _PaymentTile(payment: payments[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Payments',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...['all', 'paid', 'unpaid', 'overdue'].map((f) => ListTile(
                  title: Text(f[0].toUpperCase() + f.substring(1),
                      style: const TextStyle(color: AppTheme.textPrimary)),
                  trailing: _filter == f
                      ? const Icon(Icons.check, color: AppTheme.primaryPurple)
                      : null,
                  onTap: () {
                    setState(() => _filter = f);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          MemberAvatar(name: payment.memberName, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.memberName,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(payment.planName,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                Text(payment.paymentDate.isEmpty
                    ? payment.dueDate
                    : payment.paymentDate,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('PKR ${payment.amount.toInt()}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              StatusBadge(status: payment.status),
            ],
          ),
        ],
      ),
    );
  }
}
