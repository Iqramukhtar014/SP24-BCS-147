import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _total = 0, _active = 0, _expired = 0, _inactive = 0;
  double _revenue = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final total = await FirebaseService.getMembersCount();
    final active = await FirebaseService.getActiveMembersCount();
    final revenue = await FirebaseService.getTotalRevenue();
    if (mounted) {
      setState(() {
        _total = total;
        _active = active;
        _expired = (total * 0.16).round();
        _inactive = total - active - _expired;
        _revenue = revenue;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: AppTheme.primaryPurple, size: 18),
            label: const Text('Export PDF',
                style: TextStyle(color: AppTheme.primaryPurple)),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppTheme.primaryPurple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Row
                  Row(children: [
                    Expanded(
                        child: _MetricCard(
                            label: 'Total Revenue',
                            value: 'PKR ${_revenue.toInt()}',
                            icon: Icons.attach_money,
                            color: AppTheme.primaryPurple)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _MetricCard(
                            label: 'Total Members',
                            value: '$_total',
                            icon: Icons.people_outline,
                            color: AppTheme.info)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _MetricCard(
                            label: 'Attendance',
                            value: '${(_active * 0.7).toInt()}%',
                            icon: Icons.event_available_outlined,
                            color: AppTheme.success)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _MetricCard(
                            label: 'Growth',
                            value: '+15%',
                            icon: Icons.trending_up,
                            color: AppTheme.warning)),
                  ]),
                  const SizedBox(height: 24),
                  // Revenue chart
                  DarkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Revenue Overview'),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 300,
                              barGroups: _revenueBarGroups(),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (v) => FlLine(
                                  color: const Color(0xFF2A2A3A),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      const months = [
                                        '1 May', '10 May', '20 May', '31 May'
                                      ];
                                      final i = v.toInt();
                                      if (i < 0 || i >= months.length)
                                        return const SizedBox();
                                      return Text(months[i],
                                          style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 9));
                                    },
                                    reservedSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Membership status pie
                  DarkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Membership Status'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 160,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 45,
                                    sections: [
                                      PieChartSectionData(
                                        color: AppTheme.success,
                                        value: _active.toDouble(),
                                        title: '',
                                        radius: 30,
                                      ),
                                      PieChartSectionData(
                                        color: AppTheme.error,
                                        value: _expired.toDouble(),
                                        title: '',
                                        radius: 30,
                                      ),
                                      PieChartSectionData(
                                        color: AppTheme.textMuted,
                                        value: _inactive.toDouble().clamp(1, double.infinity),
                                        title: '',
                                        radius: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Legend(color: AppTheme.success,
                                    label: 'Active',
                                    value: '$_active ($_active%)',
                                    percent: _total == 0 ? 0 : (_active / _total * 100).round()),
                                const SizedBox(height: 8),
                                _Legend(color: AppTheme.error,
                                    label: 'Expired',
                                    value: '',
                                    percent: _total == 0 ? 0 : (_expired / _total * 100).round()),
                                const SizedBox(height: 8),
                                _Legend(color: AppTheme.textMuted,
                                    label: 'Inactive',
                                    value: '',
                                    percent: _total == 0 ? 0 : (_inactive.clamp(0, _total) / _total * 100).round()),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  List<BarChartGroupData> _revenueBarGroups() {
    final data = [80.0, 150.0, 220.0, 250.0];
    return data
        .asMap()
        .entries
        .map((e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  gradient: AppTheme.primaryGradient,
                  width: 28,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ))
        .toList();
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final int percent;

  const _Legend(
      {required this.color,
      required this.label,
      required this.value,
      required this.percent});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text('$label ($percent%)',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    ]);
  }
}
