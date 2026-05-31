import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../members/member_list_screen.dart';
import '../attendance/attendance_screen.dart';
import '../payments/payments_screen.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MemberListScreen(),
    const AttendanceScreen(),
    const PaymentsScreen(),
    const _MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A3A), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                index: 0,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Members',
                index: 1,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                icon: Icons.event_available_outlined,
                activeIcon: Icons.event_available,
                label: 'Attendance',
                index: 2,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                icon: Icons.payment_outlined,
                activeIcon: Icons.payment,
                label: 'Payments',
                index: 3,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                icon: Icons.more_horiz,
                activeIcon: Icons.more_horiz,
                label: 'More',
                index: 4,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : AppTheme.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryPurple : AppTheme.textMuted,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// More screen with extra navigation options
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'icon': Icons.card_membership_outlined,
        'label': 'Membership Plans',
        'subtitle': 'Manage pricing plans',
        'route': '/plans',
        'gradient': AppTheme.primaryGradient,
      },
      {
        'icon': Icons.sports_outlined,
        'label': 'Trainers',
        'subtitle': 'Manage gym trainers',
        'route': '/trainers',
        'gradient': AppTheme.greenGradient,
      },
      {
        'icon': Icons.bar_chart_outlined,
        'label': 'Reports',
        'subtitle': 'View revenue & stats',
        'route': '/reports',
        'gradient': AppTheme.blueGradient,
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'Payment Reminders',
        'subtitle': 'Notify unpaid members',
        'route': '/payment-reminders',
        'gradient': AppTheme.orangeGradient,
      },
      {
        'icon': Icons.notifications_none_outlined,
        'label': 'Notifications',
        'subtitle': 'View all notifications',
        'route': '/notifications',
        'gradient': const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Profile & Settings',
        'subtitle': 'Manage your account',
        'route': '/settings',
        'gradient': const LinearGradient(
          colors: [Color(0xFF373B44), Color(0xFF4286f4)],
        ),
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final opt = options[i];
          return GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, opt['route'] as String),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0xFF2A2A3A), width: 1),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: opt['gradient'] as Gradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: ((opt['gradient'] as LinearGradient)
                                    .colors
                                    .first)
                                .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(opt['icon'] as IconData,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt['label'] as String,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(opt['subtitle'] as String,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textMuted, size: 20),
              ]),
            ),
          );
        },
      ),
    );
  }
}
