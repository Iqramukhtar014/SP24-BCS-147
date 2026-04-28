// ============================================================
// screens/home_screen.dart — Main input screen
// 📸 SCREENSHOT 2: Home / Input Screen
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/bmi_result.dart';
import '../widgets/shared_widgets.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── State variables ────────────────────────────────────────
  bool _isMale = true;       // gender selection
  double _height = 170.0;    // cm  (slider)
  int _weight = 65;          // kg
  int _age = 24;             // years

  // ── Validation & navigation ───────────────────────────────

  void _onCalculate() {
    // Validate — height and weight must be positive
    if (_height <= 0 || _weight <= 0 || _age <= 0) {
      _showErrorDialog();
      return;
    }

    final result = BMIResult.calculate(
      heightCm: _height,
      weightKg: _weight.toDouble(),
      age: _age,
      isMale: _isMale,
    );

    // 📸 SCREENSHOT: Navigate to Result Screen
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(result: result),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  // 📸 SCREENSHOT 3: Error Dialog
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          side: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppColors.accent),
            const SizedBox(width: 8),
            const Text(
              'Invalid Input',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Please enter valid height and weight.\n'
          'All values must be greater than zero.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // 📸 SCREENSHOT POINT: Home / Input Screen
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'BMI Calculator',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Gender selection ─────────────────────────
              Row(
                children: [
                  GenderCard(
                    label: 'MALE',
                    icon: Icons.male_rounded,
                    isSelected: _isMale,
                    onTap: () => setState(() => _isMale = true),
                  ),
                  GenderCard(
                    label: 'FEMALE',
                    icon: Icons.female_rounded,
                    isSelected: !_isMale,
                    onTap: () => setState(() => _isMale = false),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Height slider ────────────────────────────
              _buildHeightCard(),

              const SizedBox(height: 12),

              // ── Weight & Age row ─────────────────────────
              Row(
                children: [
                  Expanded(child: _buildCounterCard('WEIGHT', _weight, 'kg',
                      onDecrement: () {
                    if (_weight > 1) setState(() => _weight--);
                  }, onIncrement: () {
                    if (_weight < 300) setState(() => _weight++);
                  })),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCounterCard('AGE', _age, 'yr',
                      onDecrement: () {
                    if (_age > 1) setState(() => _age--);
                  }, onIncrement: () {
                    if (_age < 120) setState(() => _age++);
                  })),
                ],
              ),

              const SizedBox(height: 28),

              // ── Calculate button ─────────────────────────
              PrimaryButton(
                label: 'CALCULATE',
                onPressed: _onCalculate,
                icon: Icons.calculate_rounded,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Height card with custom slider ────────────────────────

  Widget _buildHeightCard() {
    return RoundedCard(
      child: Column(
        children: [
          Text('HEIGHT', style: AppTextStyles.labelSmall),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _height.round().toString(),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'cm',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.sliderActive,
              inactiveTrackColor: AppColors.sliderInactive,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withOpacity(0.2),
            ),
            child: Slider(
              min: 50,
              max: 250,
              value: _height,
              onChanged: (v) => setState(() => _height = v),
            ),
          ),
        ],
      ),
    );
  }

  // ── Generic counter card (weight / age) ───────────────────

  Widget _buildCounterCard(
    String label,
    int value,
    String unit, {
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return RoundedCard(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CounterButton(
                icon: Icons.remove_rounded,
                onPressed: onDecrement,
              ),
              const SizedBox(width: 20),
              CounterButton(
                icon: Icons.add_rounded,
                onPressed: onIncrement,
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
