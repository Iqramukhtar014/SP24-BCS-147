// lib/screens/success_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/submission_model.dart';
import '../utils/app_constants.dart';
import '../widgets/app_widgets.dart';
import 'all_records_screen.dart';

class SuccessScreen extends StatefulWidget {
  final Submission submission;
  const SuccessScreen({super.key, required this.submission});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkScale;
  late Animation<double> _fade;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));

    _fade = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn));

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8FFF5), Color(0xFFF0EBFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Confetti dots
                _buildConfettiDots(),
                const SizedBox(height: 16),

                // Animated check circle
                ScaleTransition(
                  scale: _checkScale,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.successColor.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 58,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Column(
                      children: [
                        Text(
                          'Submission Successful!',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your data has been saved successfully.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppConstants.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // Summary card
                        _buildSummaryCard(),

                        const SizedBox(height: 36),

                        // View All Records button
                        GradientButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AllRecordsScreen()),
                              (route) => route.isFirst,
                            );
                          },
                          text: 'View All Records',
                          icon: Icons.list_alt_rounded,
                        ),

                        const SizedBox(height: 14),

                        // Add another
                        OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.popUntil(context, (r) => r.isFirst),
                          icon: const Icon(Icons.add_rounded,
                              color: AppConstants.primaryColor),
                          label: Text(
                            'Add Another',
                            style: GoogleFonts.poppins(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusM),
                            ),
                            side: const BorderSide(
                                color: AppConstants.primaryColor, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            _summaryRow(Icons.person_outline_rounded, 'Name',
                widget.submission.fullName),
            _divider(),
            _summaryRow(
                Icons.email_outlined, 'Email', widget.submission.email),
            _divider(),
            _summaryRow(
                Icons.phone_outlined, 'Phone', widget.submission.phone),
            _divider(),
            _summaryRow(Icons.wc_rounded, 'Gender', widget.submission.gender),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppConstants.primaryColor),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppConstants.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppConstants.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, color: AppConstants.borderColor.withOpacity(0.5));

  Widget _buildConfettiDots() {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              left: 60,
              top: 5,
              child: _dot(const Color(0xFFEF4444), 10)),
          Positioned(
              right: 70,
              top: 8,
              child: _dot(const Color(0xFF10B981), 8)),
          Positioned(
              left: 100,
              bottom: 4,
              child: _dot(const Color(0xFFF59E0B), 7)),
          Positioned(
              right: 100,
              bottom: 2,
              child: _dot(const Color(0xFF6366F1), 9)),
          Positioned(
              left: 40,
              bottom: 10,
              child: _dot(const Color(0xFF06B6D4), 6)),
          Positioned(
              right: 40,
              top: 4,
              child: _dot(const Color(0xFFEC4899), 8)),
        ],
      ),
    );
  }

  Widget _dot(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
