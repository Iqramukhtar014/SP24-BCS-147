import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalMembers = 0;
  int _activeMembers = 0;
  int _expiredMembers = 0;
  double _monthlyRevenue = 0;
  int _trainersCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final total = await FirebaseService.getMembersCount();
    final active = await FirebaseService.getActiveMembersCount();
    final revenue = await FirebaseService.getTotalRevenue();
    final trainers =
        await FirebaseService.getTrainers().first.then((l) => l.length);
    if (mounted) {
      setState(() {
        _totalMembers = total;
        _activeMembers = active;
        _expiredMembers = total - active;
        _monthlyRevenue = revenue;
        _trainersCount = trainers;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: AppTheme.primaryPurple,
          backgroundColor: AppTheme.cardDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildRevenueChart(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildRecentActivity(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Welcome, Admin',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          const Text('Manage your gym efficiently',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ]),
        Row(children: [
          IconButton(
            icon: Stack(children: [
              const Icon(Icons.notifications_outlined,
                  color: AppTheme.textSecondary, size: 26),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppTheme.error, shape: BoxShape.circle),
                ),
              ),
            ]),
            onPressed: () =>
                Navigator.pushNamed(context, '/notifications'),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildStatsGrid() {
    if (_loading) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: List.generate(6, (_) => const LoadingShimmer(width: double.infinity, height: 90, borderRadius: 16)),
      );
    }

    final stats = [
      {
        'title': 'Total Members',
        'value': '$_totalMembers',
        'icon': Icons.people_outline,
        'gradient': AppTheme.primaryGradient,
      },
      {
        'title': 'Active Memberships',
        'value': '$_activeMembers',
        'icon': Icons.verified_user_outlined,
        'gradient': AppTheme.greenGradient,
      },
      {
        'title': 'Expired Memberships',
        'value': '$_expiredMembers',
        'icon': Icons.cancel_outlined,
        'gradient': AppTheme.orangeGradient,
      },
      {
        'title': 'Monthly Revenue',
        'value': 'PKR ${_monthlyRevenue.toInt()}',
        'icon': Icons.attach_money,
        'gradient': AppTheme.blueGradient,
      },
      {
        'title': 'Today Attendance',
        'value': '${(_activeMembers * 0.7).toInt()}/${_totalMembers}',
        'icon': Icons.event_available_outlined,
        'gradient': LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
      },
      {
        'title': 'Trainers',
        'value': '$_trainersCount',
        'icon': Icons.sports_outlined,
        'gradient': LinearGradient(colors: [Color(0xFFf953c6), Color(0xFFb91d73)]),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => StatCard(
        title: stats[i]['title'] as String,
        value: stats[i]['value'] as String,
        icon: stats[i]['icon'] as IconData,
        gradient: stats[i]['gradient'] as LinearGradient,
      ),
    );
  }

  Widget _buildRevenueChart() {
    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Monthly Revenue',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('+15%',
                  style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          const Text('PKR 250,000',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: const Color(0xFF2A2A3A),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const labels = ['1W', '2W', '3W', '4W', '5W'];
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) return const SizedBox();
                        return Text(labels[i],
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 10));
                      },
                      reservedSize: 22,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 30),
                      FlSpot(1, 80),
                      FlSpot(2, 55),
                      FlSpot(3, 150),
                      FlSpot(4, 200),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.accentPurple]),
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPurple.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minX: 0,
                maxX: 4,
                minY: 0,
                maxY: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.person_add_outlined, 'label': 'Add Member', 'route': '/add-member'},
      {'icon': Icons.people_outlined, 'label': 'Members', 'route': '/members'},
      {'icon': Icons.event_available_outlined, 'label': 'Attendance', 'route': '/attendance'},
      {'icon': Icons.payment_outlined, 'label': 'Payments', 'route': '/payments'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions
              .map((a) => _QuickActionButton(
                    icon: a['icon'] as IconData,
                    label: a['label'] as String,
                    onTap: () =>
                        Navigator.pushNamed(context, a['route'] as String),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Activities',
          actionText: 'View All',
          onAction: () => Navigator.pushNamed(context, '/notifications'),
        ),
        const SizedBox(height: 12),
        DarkCard(
          padding: EdgeInsets.zero,
          child: StreamBuilder(
            stream: FirebaseService.getMembers(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final members = snap.data!.take(4).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                separatorBuilder: (_, __) => const Divider(
                    color: Color(0xFF2A2A3A), height: 1, indent: 64),
                itemBuilder: (_, i) {
                  final m = members[i];
                  return ListTile(
                    leading: MemberAvatar(name: m.fullName),
                    title: Text(m.fullName,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(m.membershipPlan,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                    trailing: StatusBadge(status: m.status),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
