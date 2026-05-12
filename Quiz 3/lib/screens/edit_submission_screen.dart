// lib/screens/edit_submission_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/submission_model.dart';
import '../services/submission_service.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';
import '../widgets/app_widgets.dart';

class EditSubmissionScreen extends StatefulWidget {
  final Submission submission;
  const EditSubmissionScreen({super.key, required this.submission});

  @override
  State<EditSubmissionScreen> createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedGender;
  String? _genderError;
  bool _isLoading = false;
  bool _hasChanges = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final SubmissionService _service = SubmissionService();

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing data
    _nameController =
        TextEditingController(text: widget.submission.fullName);
    _emailController =
        TextEditingController(text: widget.submission.email);
    _phoneController =
        TextEditingController(text: widget.submission.phone);
    _addressController =
        TextEditingController(text: widget.submission.address);
    _selectedGender = widget.submission.gender;

    // Track changes
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _addressController,
    ]) {
      c.addListener(() => setState(() => _hasChanges = true));
    }

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateSubmission() async {
    setState(() {
      _genderError = Validators.validateGender(_selectedGender);
    });

    if (!_formKey.currentState!.validate() || _genderError != null) return;

    setState(() => _isLoading = true);

    try {
      final updated = widget.submission.copyWith(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gender: _selectedGender,
      );

      await _service.updateSubmission(updated);

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Submission updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
            context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
            title: Text('Discard changes?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: Text(
              'You have unsaved changes. Are you sure you want to leave?',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppConstants.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Stay',
                    style: GoogleFonts.poppins(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Discard',
                    style: GoogleFonts.poppins(
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppConstants.surfaceColor,
        body: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (await _onWillPop()) Navigator.pop(context);
                            },
                            icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20),
                          ),
                          Expanded(
                            child: Text(
                              'Edit Submission',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Delete icon in app bar
                          IconButton(
                            onPressed: () => _confirmDelete(),
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ),
                    // Illustration
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_document,
                          size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Update the details below',
                      style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Form
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(AppConstants.paddingM),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildFormCard(),
                          const SizedBox(height: 16),
                          GradientButton(
                            onPressed: _updateSubmission,
                            isLoading: _isLoading,
                            text: 'Update',
                            icon: Icons.sync_rounded,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter full name',
              prefixIcon: Icons.person_outline_rounded,
              validator: Validators.validateFullName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter email address',
              prefixIcon: Icons.email_outlined,
              validator: Validators.validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter phone number',
              prefixIcon: Icons.phone_outlined,
              validator: Validators.validatePhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter address',
              prefixIcon: Icons.location_on_outlined,
              validator: Validators.validateAddress,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            GenderRadioGroup(
              selectedGender: _selectedGender,
              onChanged: (val) {
                setState(() {
                  _selectedGender = val;
                  _genderError = null;
                  _hasChanges = true;
                });
              },
              errorText: _genderError,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_rounded,
                    color: AppConstants.errorColor, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Delete Submission?',
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppConstants.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusM)),
                        side: const BorderSide(
                            color: AppConstants.borderColor),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.poppins(
                              color: AppConstants.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.errorColor,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusM)),
                      ),
                      child: Text('Delete',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _service.deleteSubmission(widget.submission.id!);
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Submission deleted');
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.showError(
              context, e.toString().replaceAll('Exception: ', ''));
        }
      }
    }
  }
}
