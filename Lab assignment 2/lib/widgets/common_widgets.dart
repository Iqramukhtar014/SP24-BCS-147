// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Purple gradient button
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Stat card widget
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Difficulty progress row
class DifficultyStatRow extends StatelessWidget {
  final String difficulty;
  final int wins;
  final int total;
  final Color color;

  const DifficultyStatRow({
    super.key,
    required this.difficulty,
    required this.wins,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? wins / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              difficulty,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
            ),
            Text(
              '$wins / $total',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// Animated result icon
class ResultIcon extends StatelessWidget {
  final String result;

  const ResultIcon({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;

    switch (result) {
      case 'win':
        bgColor = AppTheme.success;
        icon = Icons.emoji_events_rounded;
        break;
      case 'too_high':
        bgColor = AppTheme.error;
        icon = Icons.trending_up_rounded;
        break;
      default:
        bgColor = AppTheme.warning;
        icon = Icons.trending_down_rounded;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 52),
    );
  }
}
