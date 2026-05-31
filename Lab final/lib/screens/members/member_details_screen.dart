import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MemberDetailsScreen extends StatelessWidget {
  final MemberModel member;

  const MemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.darkBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/add-member',
                    arguments: {'edit': member}),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPurple, Color(0xFF12101E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    MemberAvatar(
                        name: member.fullName,
                        photoUrl: member.profilePhoto,
                        size: 80),
                    const SizedBox(height: 12),
                    Text(member.fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(member.membershipPlan,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Quick info
                  Row(children: [
                    Expanded(
                        child: _InfoCard(
                            label: 'Age',
                            value: _calcAge(member.dateOfBirth),
                            icon: Icons.cake_outlined)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _InfoCard(
                            label: 'Member ID',
                            value: member.memberId,
                            icon: Icons.badge_outlined)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _InfoCard(
                            label: 'Height',
                            value: '${member.height} ft',
                            icon: Icons.height_outlined)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _InfoCard(
                            label: 'Weight',
                            value: '${member.weight} kg',
                            icon: Icons.monitor_weight_outlined)),
                  ]),
                  const SizedBox(height: 20),
                  // Personal Info
                  _SectionCard(
                    title: 'Personal Information',
                    children: [
                      _DetailRow('Phone', member.phone),
                      _DetailRow('Email', member.email),
                      _DetailRow('CNIC', member.cnic),
                      _DetailRow('Address', member.address),
                      _DetailRow('Height', '${member.height} ft'),
                      _DetailRow('Weight', '${member.weight} kg'),
                      _DetailRow('Medical Notes',
                          member.medicalNotes.isEmpty ? 'No any medical issue' : member.medicalNotes),
                      _DetailRow('Join Date', member.joiningDate),
                      _DetailRow('Trainer', member.trainerName.isEmpty ? 'Not assigned' : member.trainerName),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Status card
                  DarkCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Membership Status',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600)),
                        StatusBadge(status: member.status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Actions
                  Row(children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/payments'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          icon: const Icon(Icons.payment_outlined,
                              color: Colors.white, size: 18),
                          label: const Text('Payment History',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppTheme.error, size: 22),
                        onPressed: () async {
                          final ok = await showConfirmDialog(context,
                              title: 'Delete Member',
                              message:
                                  'Are you sure you want to delete ${member.fullName}?');
                          if (ok) {
                            await FirebaseService.deleteMember(member.id);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calcAge(String dob) {
    if (dob.isEmpty) return 'N/A';
    try {
      final birth = DateTime.parse(dob);
      final now = DateTime.now();
      return '${now.year - birth.year} Years';
    } catch (_) {
      return 'N/A';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryPurple, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
