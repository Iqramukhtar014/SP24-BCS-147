// lib/screens/all_records_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/submission_model.dart';
import '../services/submission_service.dart';
import '../utils/app_constants.dart';
import '../widgets/app_widgets.dart';
import 'edit_submission_screen.dart';
import 'home_screen.dart';

class AllRecordsScreen extends StatefulWidget {
  const AllRecordsScreen({super.key});

  @override
  State<AllRecordsScreen> createState() => _AllRecordsScreenState();
}

class _AllRecordsScreenState extends State<AllRecordsScreen> {
  final SubmissionService _service = SubmissionService();
  final TextEditingController _searchController = TextEditingController();

  List<Submission> _allSubmissions = [];
  List<Submission> _filtered = [];
  bool _isLoading = true;
  String? _error;
  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_allSubmissions)
          : _allSubmissions.where((s) {
              return s.fullName.toLowerCase().contains(q) ||
                  s.email.toLowerCase().contains(q) ||
                  s.phone.contains(q);
            }).toList();
    });
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.getAllSubmissions();
      setState(() {
        _allSubmissions = data;
        _filtered = List.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSubmission(Submission submission) async {
    final confirm = await _showDeleteDialog(submission);
    if (!confirm) return;

    try {
      await _service.deleteSubmission(submission.id!);
      setState(() {
        _allSubmissions.removeWhere((s) => s.id == submission.id);
        _filtered.removeWhere((s) => s.id == submission.id);
      });
      if (mounted) {
        AppSnackBar.showSuccess(context, 'Submission deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
            context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<bool> _showDeleteDialog(Submission submission) async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black54,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trash icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppConstants.errorColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: AppConstants.errorColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Delete Submission?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to delete ${submission.fullName}\'s record?\nThis action cannot be undone.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppConstants.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusM),
                            ),
                            side: const BorderSide(
                                color: AppConstants.borderColor),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.errorColor,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusM),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                        ),
                        Expanded(
                          child: Text(
                            'All Submissions',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: _loadSubmissions,
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppConstants.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search by name, email or phone...',
                          hintStyle: GoogleFonts.poppins(
                            color: AppConstants.textSecondary,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppConstants.textSecondary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearch();
                                  },
                                  icon: const Icon(Icons.close_rounded,
                                      color: AppConstants.textSecondary,
                                      size: 18),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Records count badge
          if (!_isLoading && _error == null && _filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Text(
                      '${_filtered.length} record${_filtered.length != 1 ? 's' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading submissions...',
              style: GoogleFonts.poppins(
                  color: AppConstants.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 64, color: AppConstants.errorColor),
              const SizedBox(height: 16),
              Text(
                'Failed to load records',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.poppins(
                    color: AppConstants.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadSubmissions,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return EmptyStateWidget(
        icon: _searchController.text.isNotEmpty
            ? Icons.search_off_rounded
            : Icons.inbox_rounded,
        title: _searchController.text.isNotEmpty
            ? 'No results found'
            : 'No Submissions Yet',
        subtitle: _searchController.text.isNotEmpty
            ? 'Try a different search term'
            : 'Add your first submission using the + button below',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      color: AppConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final submission = _filtered[index];
          return _buildRecordCard(submission, index);
        },
      ),
    );
  }

  Widget _buildRecordCard(Submission submission, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => _navigateToEdit(submission),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                // Avatar
                AvatarCircle(
                  initials: submission.initials,
                  colorIndex: index,
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        submission.email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 12,
                              color: AppConstants.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            submission.phone,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              submission.gender,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    // Edit
                    GestureDetector(
                      onTap: () => _navigateToEdit(submission),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color:
                              AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 18,
                            color: AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Delete
                    GestureDetector(
                      onTap: () => _deleteSubmission(submission),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color:
                              AppConstants.errorColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppConstants.errorColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(Submission submission) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EditSubmissionScreen(submission: submission)),
    ).then((_) => _loadSubmissions());
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _navItem(1, Icons.list_alt_rounded, Icons.list_alt_outlined,
                'Records'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive
                    ? AppConstants.primaryColor
                    : AppConstants.textSecondary,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppConstants.primaryColor
                      : AppConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
