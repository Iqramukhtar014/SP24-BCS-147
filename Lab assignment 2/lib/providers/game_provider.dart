// lib/providers/game_provider.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/difficulty.dart';
import '../models/game_result.dart';
import '../database/database_helper.dart';

class GameProvider extends ChangeNotifier {
  Difficulty _selectedDifficulty = Difficulty.easy;
  int? _secretNumber;
  List<GameResult> _history = [];
  Map<String, dynamic> _stats = {};
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = false;

  Difficulty get selectedDifficulty => _selectedDifficulty;
  int? get secretNumber => _secretNumber;
  List<GameResult> get history => _history;
  Map<String, dynamic> get stats => _stats;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get isLoading => _isLoading;

  GameProvider() {
    _loadPreferences();
    loadHistory();
    loadStats();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    notifyListeners();
  }

  Future<void> toggleSound(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    notifyListeners();
  }

  Future<void> toggleVibration(bool value) async {
    _vibrationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', value);
    notifyListeners();
  }

  void setDifficulty(Difficulty difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void generateNewNumber() {
    final random = Random();
    _secretNumber = random.nextInt(_selectedDifficulty.max) +
        _selectedDifficulty.min;
    notifyListeners();
  }

  /// Returns the GameResult after evaluating the guess
  Future<GameResult> submitGuess(int guess) async {
    _secretNumber ??= (Random().nextInt(_selectedDifficulty.max) +
        _selectedDifficulty.min);

    final correct = _secretNumber!;
    String result;
    if (guess == correct) {
      result = 'win';
    } else if (guess > correct) {
      result = 'too_high';
    } else {
      result = 'too_low';
    }

    final gameResult = GameResult(
      guessedNumber: guess,
      correctNumber: correct,
      result: result,
      difficulty: _selectedDifficulty.name,
      timestamp: DateTime.now(),
    );

    await DatabaseHelper.instance.insertResult(gameResult);
    await loadHistory();
    await loadStats();

    // Reset secret number if win
    if (result == 'win') {
      _secretNumber = null;
    }

    return gameResult;
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    _history = await DatabaseHelper.instance.getAllResults();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStats() async {
    _stats = await DatabaseHelper.instance.getStats();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await DatabaseHelper.instance.clearAllHistory();
    _secretNumber = null;
    await loadHistory();
    await loadStats();
  }

  void resetGame() {
    _secretNumber = null;
    notifyListeners();
  }
}
