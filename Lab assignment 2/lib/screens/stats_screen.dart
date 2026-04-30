// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final stats = provider.stats;

    final totalGames = stats['totalGames'] as int? ?? 0;
    final totalWins = stats['totalWins'] as int? ?? 0;
    final winPct = totalGames > 0 ? (totalWins / totalGames * 100) : 0.0;
    final byDiff =
        stats['byDifficulty'] as Map<String, dynamic>? ?? {};

    Map<String, Map<String, int>> diffStats = {};
    for (final key in byDiff.keys) {
      final v = byDiff[key] as Map<String, dynamic>? ?? {};
      diffStats[key] = {
        'total': (v['total'] as int?) ?? 0,
        'wins': (v['wins'] as int?) ?? 0,
      };
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top stat cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Games',
                    value: '$totalGames',
                    icon: Icons.sports_esports_rounded,
                    iconColor: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Total Wins',
                    value: '$totalWins',
                    icon: Icons.emoji_events_rounded,
                    iconColor: AppTheme.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Win percentage card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Win Percentage',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${winPct.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: winPct / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primary),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalWins / $totalGames',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // By difficulty
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'By Difficulty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DifficultyStatRow(
                      difficulty: 'Easy (1 - 20)',
                      wins: diffStats['Easy']?['wins'] ?? 0,
                      total: diffStats['Easy']?['total'] ?? 0,
                      color: AppTheme.success,
                    ),
                    const SizedBox(height: 16),
                    DifficultyStatRow(
                      difficulty: 'Medium (1 - 50)',
                      wins: diffStats['Medium']?['wins'] ?? 0,
                      total: diffStats['Medium']?['total'] ?? 0,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(height: 16),
                    DifficultyStatRow(
                      difficulty: 'Hard (1 - 100)',
                      wins: diffStats['Hard']?['wins'] ?? 0,
                      total: diffStats['Hard']?['total'] ?? 0,
                      color: AppTheme.error,
                    ),
                  ],
                ),
              ),
            ),

            if (totalGames == 0) ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No stats yet — play some games!',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
