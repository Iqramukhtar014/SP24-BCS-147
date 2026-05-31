import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PaymentReminderScreen extends StatefulWidget {
  const PaymentReminderScreen({super.key});

  @override
  State<PaymentReminderScreen> createState() => _PaymentReminderScreenState();
}

class _PaymentReminderScreenState extends State<PaymentReminderScreen> {
  String _tab = 'All';
  final _tabs = ['All', 'Upcoming', 'Overdue'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Payment Reminders')),
      body: StreamBuilder<List<PaymentModel>>(
        stream: FirebaseService.getPayments(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.primaryPurple));
          }

          var payments = snap.data!.where((p) => p.status != 'paid').toList();
          if (_tab == 'Upcoming') {
            payments = payments.where((p) => p.status == 'unpaid').toList();
          } else if (_tab == 'Overdue') {
            payments = payments.where((p) => p.status == 'overdue').toList();
          }

          return Column(
            children: [
              // Tab bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: _tabs.map((t) {
                    final selected = _tab == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            gradient:
                                selected ? AppTheme.primaryGradient : null,
                            color: selected ? null : AppTheme.cardDark2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: selected
                                    ? AppTheme.primaryPurple
                                    : const Color(0xFF2A2A3A)),
                          ),
                          child: Text(t,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: payments.isEmpty
                    ? const EmptyState(
                        icon: Icons.notifications_off_outlined,
                        title: 'No Reminders',
                        subtitle: 'All payments are up to date')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: payments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final p = payments[i];
                          final isOverdue = p.status == 'overdue';
                          return DarkCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(children: [
                              MemberAvatar(name: p.memberName, size: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.memberName,
                                        style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    Text('Due Date: ${p.dueDate}',
                                        style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('PKR ${p.amount.toInt()}',
                                      style: TextStyle(
                                          color: isOverdue
                                              ? AppTheme.error
                                              : AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  StatusBadge(
                                      status: isOverdue
                                          ? 'Overdue'
                                          : 'Due in 3 days'),
                                ],
                              ),
                            ]),
                          );
                        },
                      ),
              ),
              // Send Reminders button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ]),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Reminders sent to all unpaid members'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.send_outlined, color: Colors.white),
                      label: const Text('Send Reminders',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
