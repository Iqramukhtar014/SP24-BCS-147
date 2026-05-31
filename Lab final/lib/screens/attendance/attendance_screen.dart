import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/member_model.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<MemberModel> _allMembers = [];
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    FirebaseService.getMembers().first.then((m) {
      if (mounted) setState(() => _allMembers = m);
    });
  }

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _prevDay() =>
      setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
  void _nextDay() {
    final next = _selectedDate.add(const Duration(days: 1));
    if (!next.isAfter(DateTime.now())) setState(() => _selectedDate = next);
  }

  Future<void> _markCheckIn(MemberModel member) async {
    final now = DateFormat('HH:mm').format(DateTime.now());
    final att = AttendanceModel(
      id: '',
      memberId: member.id,
      memberName: member.fullName,
      date: _dateStr,
      checkIn: now,
      checkOut: '',
      status: 'present',
    );
    await FirebaseService.markAttendance(att);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.fullName} checked in at $now'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined,
                color: AppTheme.textSecondary),
            onPressed: () {},
            tooltip: 'QR Scan',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: DarkCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                    onPressed: _prevDay,
                  ),
                  Column(children: [
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(DateFormat('EEEE').format(_selectedDate),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                  ]),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppTheme.textSecondary),
                    onPressed: _nextDay,
                  ),
                ],
              ),
            ),
          ),
          // Week strip
          _WeekStrip(
            selectedDate: _selectedDate,
            onDateSelected: (d) => setState(() => _selectedDate = d),
          ),
          const SizedBox(height: 8),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search members...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Attendance List
          Expanded(
            child: StreamBuilder<List<AttendanceModel>>(
              stream: FirebaseService.getAttendanceByDate(_dateStr),
              builder: (context, attSnap) {
                final attendanceToday = attSnap.data ?? [];
                final attendedIds = attendanceToday.map((a) => a.memberId).toSet();

                var members = _allMembers;
                if (_query.isNotEmpty) {
                  members = members
                      .where((m) =>
                          m.fullName.toLowerCase().contains(_query) ||
                          m.phone.contains(_query))
                      .toList();
                }

                if (members.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Members',
                    subtitle: 'Add members to track attendance',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final m = members[i];
                    final att = attendanceToday
                        .where((a) => a.memberId == m.id)
                        .firstOrNull;
                    final present = attendedIds.contains(m.id);
                    return _AttendanceTile(
                      member: m,
                      attendance: att,
                      isPresent: present,
                      onCheckIn: () => _markCheckIn(m),
                    );
                  },
                );
              },
            ),
          ),
          // Mark All Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final members = _allMembers.where((m) => m.status == 'active').toList();
                  final now = DateFormat('HH:mm').format(DateTime.now());
                  for (final m in members) {
                    await FirebaseService.markAttendance(AttendanceModel(
                      id: '', memberId: m.id, memberName: m.fullName,
                      date: _dateStr, checkIn: now, checkOut: '', status: 'present',
                    ));
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All active members marked present'),
                          backgroundColor: AppTheme.success),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text('Mark Attendance',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _WeekStrip(
      {required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
        7, (i) => today.subtract(Duration(days: 6 - i)));

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = days[i];
          final isSelected = DateFormat('yyyy-MM-dd').format(d) ==
              DateFormat('yyyy-MM-dd').format(selectedDate);
          return GestureDetector(
            onTap: () => onDateSelected(d),
            child: Container(
              width: 44,
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.cardDark2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryPurple
                        : const Color(0xFF2A2A3A)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(d).substring(0, 2),
                      style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : AppTheme.textMuted,
                          fontSize: 10)),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                      style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final MemberModel member;
  final AttendanceModel? attendance;
  final bool isPresent;
  final VoidCallback onCheckIn;

  const _AttendanceTile({
    required this.member,
    this.attendance,
    required this.isPresent,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          MemberAvatar(name: member.fullName, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (isPresent && attendance != null)
                  Row(children: [
                    _TimeChip('Check In', attendance!.checkIn, AppTheme.success),
                    const SizedBox(width: 8),
                    if (attendance!.checkOut.isNotEmpty)
                      _TimeChip('Check Out', attendance!.checkOut, AppTheme.info),
                  ])
                else
                  const Text('Absent',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          if (!isPresent)
            GestureDetector(
              onTap: onCheckIn,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.4)),
                ),
                child: const Text('Check In',
                    style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppTheme.success, size: 16),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;
  final Color color;

  const _TimeChip(this.label, this.time, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label $time',
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
