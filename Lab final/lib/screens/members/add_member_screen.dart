import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/member_model.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddMemberScreen extends StatefulWidget {
  final MemberModel? member; // null = add, non-null = edit

  const AddMemberScreen({super.key, this.member});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool get _isEdit => widget.member != null;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _medicalCtrl = TextEditingController();
  final _joiningCtrl = TextEditingController();

  String _gender = 'Male';
  String _selectedPlan = '';
  String _selectedTrainer = '';
  String _selectedTrainerId = '';

  List<PlanModel> _plans = [];
  List<TrainerModel> _trainers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (_isEdit) _populateFields();
  }

  void _populateFields() {
    final m = widget.member!;
    _nameCtrl.text = m.fullName;
    _emailCtrl.text = m.email;
    _phoneCtrl.text = m.phone;
    _cnicCtrl.text = m.cnic;
    _addressCtrl.text = m.address;
    _dobCtrl.text = m.dateOfBirth;
    _weightCtrl.text = m.weight.toString();
    _heightCtrl.text = m.height.toString();
    _medicalCtrl.text = m.medicalNotes;
    _joiningCtrl.text = m.joiningDate;
    _gender = m.gender;
    _selectedPlan = m.membershipPlan;
    _selectedTrainer = m.trainerName;
    _selectedTrainerId = m.trainerId;
  }

  Future<void> _loadData() async {
    final plans = await FirebaseService.getPlans().first;
    final trainers = await FirebaseService.getTrainers().first;
    if (mounted) {
      setState(() {
        _plans = plans;
        _trainers = trainers;
        if (_selectedPlan.isEmpty && plans.isNotEmpty) {
          _selectedPlan = plans.first.name;
        }
        _joiningCtrl.text = _joiningCtrl.text.isEmpty
            ? DateFormat('yyyy-MM-dd').format(DateTime.now())
            : _joiningCtrl.text;
      });
    }
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryPurple),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final member = MemberModel(
        id: widget.member?.id ?? '',
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        cnic: _cnicCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        gender: _gender,
        dateOfBirth: _dobCtrl.text,
        weight: double.tryParse(_weightCtrl.text) ?? 0,
        height: double.tryParse(_heightCtrl.text) ?? 0,
        medicalNotes: _medicalCtrl.text.trim(),
        joiningDate: _joiningCtrl.text,
        membershipPlan: _selectedPlan,
        trainerId: _selectedTrainerId,
        trainerName: _selectedTrainer,
        profilePhoto: widget.member?.profilePhoto ?? '',
        status: 'active',
        memberId: widget.member?.memberId ??
            '#MEM${const Uuid().v4().substring(0, 4).toUpperCase()}',
      );

      if (_isEdit) {
        await FirebaseService.updateMember(member.id, member.toMap());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Member updated successfully'),
                backgroundColor: AppTheme.success),
          );
          Navigator.pop(context);
        }
      } else {
        await FirebaseService.addMember(member);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Member added successfully'),
                backgroundColor: AppTheme.success),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl, _cnicCtrl, _addressCtrl,
      _dobCtrl, _weightCtrl, _heightCtrl, _medicalCtrl, _joiningCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Member' : 'Add Member'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryPurple))
                : const Text('Save',
                    style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Placeholder
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark2,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primaryPurple, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          color: AppTheme.textMuted, size: 32),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Add Photo',
                    style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Personal Information'),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter full name',
                controller: _nameCtrl,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Email',
                hint: 'Enter email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Phone Number',
                hint: '0300-0000000',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'CNIC',
                hint: 'XXXX-XXXXXXX-X',
                controller: _cnicCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              // Gender
              const Text('Gender',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: ['Male', 'Female', 'Other'].map((g) {
                  final selected = _gender == g;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _gender = g),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          gradient:
                              selected ? AppTheme.primaryGradient : null,
                          color: selected ? null : AppTheme.cardDark2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selected
                                  ? AppTheme.primaryPurple
                                  : const Color(0xFF2A2A3A)),
                        ),
                        child: Text(g,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Date of Birth',
                hint: 'Select date',
                controller: _dobCtrl,
                readOnly: true,
                onTap: () => _pickDate(_dobCtrl),
                suffixIcon: const Icon(Icons.calendar_today_outlined,
                    color: AppTheme.textMuted, size: 18),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Address',
                hint: 'Enter address',
                controller: _addressCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Weight (kg)',
                    hint: '75',
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Height (ft)',
                    hint: '5.8',
                    controller: _heightCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Medical Notes',
                hint: 'Any medical conditions...',
                controller: _medicalCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              _sectionTitle('Membership Details'),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Joining Date',
                hint: 'Select date',
                controller: _joiningCtrl,
                readOnly: true,
                onTap: () => _pickDate(_joiningCtrl),
                suffixIcon: const Icon(Icons.calendar_today_outlined,
                    color: AppTheme.textMuted, size: 18),
              ),
              const SizedBox(height: 14),
              // Plan Dropdown
              const Text('Membership Plan',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A3A)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPlan.isEmpty ? null : _selectedPlan,
                    hint: const Text('Select Plan',
                        style: TextStyle(color: AppTheme.textMuted)),
                    dropdownColor: AppTheme.cardDark2,
                    isExpanded: true,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    items: _plans
                        .map((p) => DropdownMenuItem(
                            value: p.name,
                            child: Text(
                                '${p.name} - PKR ${p.price.toInt()}/mo')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPlan = v ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Trainer Dropdown
              const Text('Trainer',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A3A)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTrainerId.isEmpty
                        ? null
                        : _selectedTrainerId,
                    hint: const Text('Select Trainer',
                        style: TextStyle(color: AppTheme.textMuted)),
                    dropdownColor: AppTheme.cardDark2,
                    isExpanded: true,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    items: _trainers
                        .map((t) => DropdownMenuItem(
                            value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (id) {
                      final t = _trainers.firstWhere((tr) => tr.id == id,
                          orElse: () => _trainers.first);
                      setState(() {
                        _selectedTrainerId = id ?? '';
                        _selectedTrainer = t.name;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isEdit ? 'Update Member' : 'Save Member',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Row(children: [
      Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(t,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700)),
    ]);
  }
}
