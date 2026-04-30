// lib/models/game_result.dart

class GameResult {
  final int? id;
  final int guessedNumber;
  final int correctNumber;
  final String result; // 'win', 'too_high', 'too_low'
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final DateTime timestamp;

  GameResult({
    this.id,
    required this.guessedNumber,
    required this.correctNumber,
    required this.result,
    required this.difficulty,
    required this.timestamp,
  });

  bool get isWin => result == 'win';

  String get resultLabel {
    switch (result) {
      case 'win':
        return 'Correct!';
      case 'too_high':
        return 'Too High';
      case 'too_low':
        return 'Too Low';
      default:
        return result;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guessed_number': guessedNumber,
      'correct_number': correctNumber,
      'result': result,
      'difficulty': difficulty,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      id: map['id'],
      guessedNumber: map['guessed_number'],
      correctNumber: map['correct_number'],
      result: map['result'],
      difficulty: map['difficulty'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
