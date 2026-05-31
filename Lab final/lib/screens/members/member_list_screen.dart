import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = 'all'; // all, active, expired
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.textSecondary),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-member'),
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _FilterChip(label: 'All', value: 'all', selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Active', value: 'active', selected: _filter == 'active', onTap: () => setState(() => _filter = 'active')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Expired', value: 'expired', selected: _filter == 'expired', onTap: () => setState(() => _filter = 'expired')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MemberModel>>(
              stream: FirebaseService.getMembers(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.primaryPurple));
                }
                if (!snap.hasData || snap.data!.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Members Yet',
                    subtitle: 'Add your first member to get started',
                    buttonText: 'Add Member',
                    onButton: () => Navigator.pushNamed(context, '/add-member'),
                  );
                }

                var members = snap.data!;
                if (_filter != 'all') {
                  members = members.where((m) => m.status == _filter).toList();
                }
                if (_query.isNotEmpty) {
                  members = members
                      .where((m) =>
                          m.fullName.toLowerCase().contains(_query) ||
                          m.phone.contains(_query) ||
                          m.memberId.toLowerCase().contains(_query))
                      .toList();
                }

                if (members.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No Results',
                    subtitle: 'Try a different search or filter',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _MemberTile(member: members[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Members',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...['all', 'active', 'expired', 'inactive'].map((f) => ListTile(
                  title: Text(f[0].toUpperCase() + f.substring(1),
                      style: const TextStyle(color: AppTheme.textPrimary)),
                  trailing: _filter == f
                      ? const Icon(Icons.check, color: AppTheme.primaryPurple)
                      : null,
                  onTap: () {
                    setState(() => _filter = f);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : AppTheme.cardDark2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? AppTheme.primaryPurple
                  : const Color(0xFF2A2A3A)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberModel member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(14),
      onTap: () =>
          Navigator.pushNamed(context, '/member-details', arguments: member),
      child: Row(
        children: [
          MemberAvatar(name: member.fullName, photoUrl: member.profilePhoto),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(member.phone,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(member.membershipPlan,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          StatusBadge(status: member.status),
        ],
      ),
    );
  }
}
