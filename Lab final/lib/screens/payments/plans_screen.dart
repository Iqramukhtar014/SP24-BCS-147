import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Membership Plans'),
        actions: [
          TextButton.icon(
            onPressed: () => _showPlanDialog(context),
            icon: const Icon(Icons.add, color: AppTheme.primaryPurple, size: 18),
            label: const Text('Add Plan',
                style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: StreamBuilder<List<PlanModel>>(
        stream: FirebaseService.getPlans(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.primaryPurple));
          }
          final plans = snap.data!;
          final gradients = [
            AppTheme.primaryGradient,
            AppTheme.blueGradient,
            AppTheme.greenGradient,
          ];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _PlanCard(
              plan: plans[i],
              gradient: gradients[i % gradients.length],
              context: context,
            ),
          );
        },
      ),
    );
  }

  Widget _PlanCard(
      {required PlanModel plan,
      required Gradient gradient,
      required BuildContext context}) {
    return DarkCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.card_membership,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text(
                          'PKR ${plan.price.toInt()} / Month',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...plan.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        const Icon(Icons.check_circle,
                            color: AppTheme.success, size: 16),
                        const SizedBox(width: 8),
                        Text(f,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ]),
                    )),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showPlanDialog(context, plan: plan),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryPurple),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Edit',
                          style: TextStyle(color: AppTheme.primaryPurple)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final ok = await showConfirmDialog(context,
                            title: 'Delete Plan',
                            message:
                                'Delete ${plan.name}? This cannot be undone.');
                        if (ok)
                          await FirebaseService.deletePlan(plan.id);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Delete',
                          style: TextStyle(color: AppTheme.error)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanDialog(BuildContext context, {PlanModel? plan}) {
    final nameCtrl = TextEditingController(text: plan?.name ?? '');
    final priceCtrl =
        TextEditingController(text: plan?.price.toString() ?? '');
    final durationCtrl =
        TextEditingController(text: plan?.durationMonths.toString() ?? '1');
    final featuresCtrl = TextEditingController(
        text: plan?.features.join('\n') ?? '');
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan == null ? 'Add Plan' : 'Edit Plan',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                CustomTextField(
                    label: 'Plan Name',
                    controller: nameCtrl,
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: CustomTextField(
                          label: 'Price (PKR)',
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: CustomTextField(
                          label: 'Duration (months)',
                          controller: durationCtrl,
                          keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'Features (one per line)',
                  hint: 'Gym Access\nLocker Room\n...',
                  controller: featuresCtrl,
                  maxLines: 4,
                ),
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
                        final features = featuresCtrl.text
                            .split('\n')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();
                        final p = PlanModel(
                          id: plan?.id ?? '',
                          name: nameCtrl.text.trim(),
                          price: double.tryParse(priceCtrl.text) ?? 0,
                          durationMonths:
                              int.tryParse(durationCtrl.text) ?? 1,
                          features: features,
                          accessLevel: 'standard',
                        );
                        if (plan == null) {
                          await FirebaseService.addPlan(p);
                        } else {
                          await FirebaseService.updatePlan(p.id, p.toMap());
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Text(plan == null ? 'Add Plan' : 'Update Plan',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
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
}
