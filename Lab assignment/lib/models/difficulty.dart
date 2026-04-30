// lib/models/difficulty.dart
import 'package:flutter/material.dart';

enum DifficultyLevel { easy, medium, hard }

class Difficulty {
  final DifficultyLevel level;
  final String name;
  final int min;
  final int max;
  final Color color;
  final IconData icon;

  const Difficulty({
    required this.level,
    required this.name,
    required this.min,
    required this.max,
    required this.color,
    required this.icon,
  });

  String get range => '$min - $max';
  String get label => '$name ($min - $max)';

  static const easy = Difficulty(
    level: DifficultyLevel.easy,
    name: 'Easy',
    min: 1,
    max: 20,
    color: Color(0xFF4CAF50),
    icon: Icons.sentiment_satisfied_rounded,
  );

  static const medium = Difficulty(
    level: DifficultyLevel.medium,
    name: 'Medium',
    min: 1,
    max: 50,
    color: Color(0xFF2196F3),
    icon: Icons.sentiment_neutral_rounded,
  );

  static const hard = Difficulty(
    level: DifficultyLevel.hard,
    name: 'Hard',
    min: 1,
    max: 100,
    color: Color(0xFFF44336),
    icon: Icons.sentiment_dissatisfied_rounded,
  );

  static List<Difficulty> get all => [easy, medium, hard];
}
