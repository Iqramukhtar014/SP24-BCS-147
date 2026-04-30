// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/difficulty.dart';
import '../providers/game_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _guessController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  Future<void> _submitGuess() async {
    if (!_formKey.currentState!.validate()) return;

    final gameProvider = context.read<GameProvider>();
    final guess = int.tryParse(_guessController.text.trim());
    if (guess == null) return;

    final diff = gameProvider.selectedDifficulty;
    if (guess < diff.min || guess > diff.max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please enter a number between ${diff.min} and ${diff.max}'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Generate new number if not set
    if (gameProvider.secretNumber == null) {
      gameProvider.generateNewNumber();
    }

    final result = await gameProvider.submitGuess(guess);
    _guessController.clear();
    setState(() => _isSubmitting = false);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final diff = gameProvider.selectedDifficulty;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              decoration: splashGradient(),
              child: Column(
                children: [
                  const Text(
                    'Number Guessing Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Can you guess the number?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Difficulty selector
                    const Text(
                      'Select Difficulty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: Difficulty.all.map((d) {
                        final isSelected = d.level == diff.level;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              gameProvider.setDifficulty(d);
                              gameProvider.resetGame();
                              _guessController.clear();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? d.color : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: d.color.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    d.icon,
                                    color: isSelected ? Colors.white : d.color,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    d.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    d.range,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.85)
                                          : AppTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Current game info
                    if (gameProvider.secretNumber != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppTheme.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Keep guessing! Range: ${diff.min} - ${diff.max}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Guess input
                    const Text(
                      'Enter Your Guess',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guessController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter a number (${diff.min} - ${diff.max})',
                        prefixIcon: const Icon(Icons.numbers_rounded,
                            color: AppTheme.primary),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a number';
                        }
                        final n = int.tryParse(value.trim());
                        if (n == null) {
                          return 'Please enter a valid integer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    PrimaryButton(
                      text: _isSubmitting ? 'Checking...' : 'Submit Guess',
                      onPressed: _isSubmitting ? () {} : _submitGuess,
                    ),
                    const SizedBox(height: 12),

                    // New Game button
                    if (gameProvider.secretNumber != null)
                      SecondaryButton(
                        text: 'Start New Game',
                        onPressed: () {
                          gameProvider.resetGame();
                          _guessController.clear();
                        },
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
}
