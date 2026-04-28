// ============================================================
// models/bmi_result.dart — BMI calculation logic & data model
// ============================================================

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Represents the four standard BMI categories.
enum BMICategory { underweight, normal, overweight, obese }

/// Encapsulates a single BMI calculation result.
class BMIResult {
  final double bmi;
  final BMICategory category;
  final double heightCm;
  final double weightKg;
  final int age;
  final bool isMale;

  const BMIResult({
    required this.bmi,
    required this.category,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.isMale,
  });

  // ── Derived presentation helpers ──────────────────────────

  String get bmiString => bmi.toStringAsFixed(1);

  String get categoryLabel {
    switch (category) {
      case BMICategory.underweight:
        return 'Underweight';
      case BMICategory.normal:
        return 'Normal';
      case BMICategory.overweight:
        return 'Overweight';
      case BMICategory.obese:
        return 'Obese';
    }
  }

  Color get categoryColor {
    switch (category) {
      case BMICategory.underweight:
        return AppColors.colorUnderweight;
      case BMICategory.normal:
        return AppColors.colorNormal;
      case BMICategory.overweight:
        return AppColors.colorOverweight;
      case BMICategory.obese:
        return AppColors.colorObese;
    }
  }

  String get categoryAdvice {
    switch (category) {
      case BMICategory.underweight:
        return 'You are below a healthy weight range. '
            'Focus on nutrient-dense foods and consider speaking '
            'with a healthcare provider about a healthy plan.';
      case BMICategory.normal:
        return 'Great job! Your weight is within the healthy range. '
            'Keep maintaining a balanced diet and regular physical activity.';
      case BMICategory.overweight:
        return 'You are slightly above a healthy weight range. '
            'Choose healthier foods and incorporate more regular '
            'physical activities to reduce the risks.';
      case BMICategory.obese:
        return 'Your BMI indicates obesity, which can pose health risks. '
            'Please consult a healthcare professional for a '
            'personalised plan to improve your health.';
    }
  }

  // ── Factory constructor ────────────────────────────────────

  /// Calculates BMI from height (cm) and weight (kg).
  factory BMIResult.calculate({
    required double heightCm,
    required double weightKg,
    required int age,
    required bool isMale,
  }) {
    final double heightM = heightCm / 100.0;
    final double bmi = weightKg / (heightM * heightM);

    BMICategory category;
    if (bmi < 18.5) {
      category = BMICategory.underweight;
    } else if (bmi < 25.0) {
      category = BMICategory.normal;
    } else if (bmi < 30.0) {
      category = BMICategory.overweight;
    } else {
      category = BMICategory.obese;
    }

    return BMIResult(
      bmi: bmi,
      category: category,
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      isMale: isMale,
    );
  }
}
