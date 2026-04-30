// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import '../models/game_result.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class ResultScreen extends StatefulWidget {
  final GameResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _resultColor {
    switch (widget.result.result) {
      case 'win':
        return AppTheme.success;
      case 'too_high':
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }

  String get _resultTitle {
    switch (widget.result.result) {
      case 'win':
        return 'Correct!';
      case 'too_high':
        return 'Too High!';
      default:
        return 'Too Low!';
    }
  }

  String get _resultSubtitle {
    switch (widget.result.result) {
      case 'win':
        return 'You guessed the right number.';
      case 'too_high':
        return 'The number is lower than your guess.';
      default:
        return 'The number is higher than your guess.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with scale animation
            ScaleTransition(
              scale: _scaleAnim,
              child: ResultIcon(result: widget.result.result),
            ),
            const SizedBox(height: 24),

            // Result message
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    Text(
                      _resultTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _resultColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _resultSubtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Stats card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  'Your Guess',
                                  '${widget.result.guessedNumber}',
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                ),
                                _buildStatItem(
                                  'Correct Number',
                                  '${widget.result.correctNumber}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Difficulty',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.result.difficulty == 'Easy'
                                  ? 'Easy (1 - 20)'
                                  : widget.result.difficulty == 'Medium'
                                      ? 'Medium (1 - 50)'
                                      : 'Hard (1 - 100)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    PrimaryButton(
                      text: widget.result.isWin ? 'Play Again' : 'Try Again',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      text: 'Back to Home',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
