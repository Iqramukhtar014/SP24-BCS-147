// ============================================================
// screens/result_screen.dart — BMI Result display screen
// 📸 SCREENSHOT 4: Result Screen
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bmi_result.dart';
import '../widgets/shared_widgets.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final BMIResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    // 📸 SCREENSHOT POINT: Result Screen
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your BMI Result',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── Animated BMI circle ───────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: _buildBMICircle(result),
              ),

              const SizedBox(height: 20),

              // ── Category badge ────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: _buildCategoryBadge(result),
              ),

              const SizedBox(height: 20),

              // ── Stats summary row ────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: _buildStatsSummary(result),
              ),

              const SizedBox(height: 16),

              // ── BMI scale indicator ───────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: _buildBMIScale(result),
              ),

              const SizedBox(height: 16),

              // ── Advice card ───────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: _buildAdviceCard(result),
              ),

              const SizedBox(height: 28),

              // ── Recalculate button ────────────────────────
              PrimaryButton(
                label: 'RE-CALCULATE',
                onPressed: () => Navigator.pop(context),
                icon: Icons.refresh_rounded,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── BMI Circle ────────────────────────────────────────────

  Widget _buildBMICircle(BMIResult result) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring
            CustomPaint(
              size: const Size(200, 200),
              painter: _BMIRingPainter(
                bmi: result.bmi,
                color: result.categoryColor,
              ),
            ),
            // Inner content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  result.bmiString,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: result.categoryColor,
                    height: 1.0,
                  ),
                ),
                const Text(
                  'kg/m²',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Category badge ────────────────────────────────────────

  Widget _buildCategoryBadge(BMIResult result) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      decoration: BoxDecoration(
        color: result.categoryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: result.categoryColor, width: 1.5),
      ),
      child: Text(
        result.categoryLabel.toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: result.categoryColor,
        ),
      ),
    );
  }

  // ── Stats summary ─────────────────────────────────────────

  Widget _buildStatsSummary(BMIResult result) {
    return RoundedCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('Age', '${result.age}'),
          _divider(),
          _statItem('Weight', '${result.weightKg.round()} Kg'),
          _divider(),
          _statItem('Height', '${result.heightCm.round()} Cm'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: AppColors.cardLight,
      );

  // ── BMI Scale indicator ───────────────────────────────────

  Widget _buildBMIScale(BMIResult result) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BMI Range', style: AppTextStyles.labelSmall),
          const SizedBox(height: 12),
          _ScaleRow(
            label: 'Underweight',
            range: '< 18.5',
            color: AppColors.colorUnderweight,
            isActive: result.category == BMICategory.underweight,
          ),
          _ScaleRow(
            label: 'Normal',
            range: '18.5 – 24.9',
            color: AppColors.colorNormal,
            isActive: result.category == BMICategory.normal,
          ),
          _ScaleRow(
            label: 'Overweight',
            range: '25.0 – 29.9',
            color: AppColors.colorOverweight,
            isActive: result.category == BMICategory.overweight,
          ),
          _ScaleRow(
            label: 'Obese',
            range: '≥ 30',
            color: AppColors.colorObese,
            isActive: result.category == BMICategory.obese,
          ),
        ],
      ),
    );
  }

  // ── Advice card ───────────────────────────────────────────

  Widget _buildAdviceCard(BMIResult result) {
    return RoundedCard(
      borderColor: result.categoryColor.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: result.categoryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Health Insight',
                style: AppTextStyles.labelSmall.copyWith(
                  color: result.categoryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.categoryAdvice,
            style: AppTextStyles.bodyRegular.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Scale row widget ──────────────────────────────────────────

class _ScaleRow extends StatelessWidget {
  const _ScaleRow({
    required this.label,
    required this.range,
    required this.color,
    required this.isActive,
  });

  final String label;
  final String range;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: color, width: 1)
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          // Colour dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
              color: isActive ? color : AppColors.textLabel,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle_rounded, color: color, size: 16),
          ],
        ],
      ),
    );
  }
}

// ── Custom ring painter ───────────────────────────────────────

class _BMIRingPainter extends CustomPainter {
  const _BMIRingPainter({required this.bmi, required this.color});

  final double bmi;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 14.0;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.cardLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc — map BMI 0–40 → 0–1.0
    final progress = (bmi.clamp(0, 40) / 40).toDouble();

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,           // start at top
      2 * math.pi * progress, // sweep
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_BMIRingPainter old) =>
      old.bmi != bmi || old.color != color;
}
