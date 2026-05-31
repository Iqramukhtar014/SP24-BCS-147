import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class TrainerScreen extends StatelessWidget {
  const TrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Trainers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTrainer(context),
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<TrainerModel>>(
        stream: FirebaseService.getTrainers(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.primaryPurple));
          }
          final trainers = snap.data!;
          if (trainers.isEmpty) {
            return EmptyState(
              icon: Icons.sports_outlined,
              title: 'No Trainers',
              subtitle: 'Add trainers to assign to members',
              buttonText: 'Add Trainer',
              onButton: () => _showAddTrainer(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trainers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _TrainerCard(trainer: trainers[i], context: context),
          );
        },
      ),
    );
  }

  Widget _TrainerCard(
      {required TrainerModel trainer, required BuildContext context}) {
    return DarkCard(
      child: Row(
        children: [
          MemberAvatar(name: trainer.name, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.fitness_center,
                      color: AppTheme.primaryPurple, size: 13),
                  const SizedBox(width: 4),
                  Text(trainer.specialization,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.star_outline,
                      color: AppTheme.warning, size: 13),
                  const SizedBox(width: 4),
                  Text('${trainer.experience} Years Experience',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ]),
                const SizedBox(height: 3),
                Text('${trainer.assignedMembers.length} Members Assigned',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppTheme.textSecondary, size: 20),
              onPressed: () => _showAddTrainer(context, trainer: trainer),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.error, size: 20),
              onPressed: () async {
                final ok = await showConfirmDialog(context,
                    title: 'Delete Trainer',
                    message:
                        'Delete ${trainer.name}?');
                if (ok)
                  await FirebaseService.deleteTrainer(trainer.id);
              },
            ),
          ]),
        ],
      ),
    );
  }

  void _showAddTrainer(BuildContext context, {TrainerModel? trainer}) {
    final nameCtrl =
        TextEditingController(text: trainer?.name ?? '');
    final specCtrl =
        TextEditingController(text: trainer?.specialization ?? '');
    final expCtrl = TextEditingController(
        text: trainer?.experience.toString() ?? '');
    final phoneCtrl =
        TextEditingController(text: trainer?.phone ?? '');
    final emailCtrl =
        TextEditingController(text: trainer?.email ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trainer == null ? 'Add Trainer' : 'Edit Trainer',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              CustomTextField(label: 'Name', controller: nameCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 10),
              CustomTextField(label: 'Specialization', controller: specCtrl),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: CustomTextField(
                    label: 'Experience (years)', controller: expCtrl,
                    keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: CustomTextField(label: 'Phone', controller: phoneCtrl,
                    keyboardType: TextInputType.phone)),
              ]),
              const SizedBox(height: 10),
              CustomTextField(label: 'Email', controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12)),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final t = TrainerModel(
                        id: trainer?.id ?? '',
                        name: nameCtrl.text.trim(),
                        specialization: specCtrl.text.trim(),
                        experience: int.tryParse(expCtrl.text) ?? 0,
                        phone: phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        profilePhoto: '',
                        assignedMembers: trainer?.assignedMembers ?? [],
                        status: 'active',
                      );
                      if (trainer == null) {
                        await FirebaseService.addTrainer(t);
                      } else {
                        await FirebaseService.updateTrainer(t.id, t.toMap());
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(trainer == null ? 'Add Trainer' : 'Update',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
