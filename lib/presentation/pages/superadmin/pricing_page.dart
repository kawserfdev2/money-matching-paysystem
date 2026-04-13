import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/injection.dart';
import '../../../domain/entities/saas_plan_entity.dart';
import '../../../logic/superadmin/saas_plan/saas_plan_bloc.dart';
import '../../../logic/superadmin/saas_plan/saas_plan_event.dart';
import '../../../logic/superadmin/saas_plan/saas_plan_state.dart';

class PricingPlansPage extends StatelessWidget {
  const PricingPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SaasPlanBloc>()..add(const LoadPlans()),
      child: const _PricingPlansView(),
    );
  }
}

class _PricingPlansView extends StatelessWidget {
  const _PricingPlansView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pricing Plans',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('🖱️ [UI] Clicking "Add New Plan"');
                    final bloc = context.read<SaasPlanBloc>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return BlocProvider.value(
                          value: bloc,
                          child: const _PlanFormDialog(),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add New Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocConsumer<SaasPlanBloc, SaasPlanState>(
                listener: (context, state) {
                  if (state is PlanError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PlanLoading || state is PlanInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PlanLoaded) {
                    if (state.plans.isEmpty) {
                      return const Center(
                        child: Text(
                          'No plans found! Create one.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 800) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 0.65,
                              ),
                          itemCount: state.plans.length,
                          itemBuilder: (context, index) {
                            return _PricingCard(plan: state.plans[index]);
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final SaasPlanEntity plan;

  const _PricingCard({required this.plan});

  void _showPlanFormDialog(BuildContext context, {SaasPlanEntity? plan}) {
    final bloc = context.read<SaasPlanBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: _PlanFormDialog(plan: plan),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = plan.isActive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 1.0 : 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFE2E8F0).withOpacity(0.5),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isActive ? const Color(0xFF1E293B) : Colors.grey,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        color: isActive ? Colors.grey : Colors.grey.shade400,
                      ),
                      onSelected: (value) {
                        debugPrint(
                          '🖱️ [UI] Pricing Plan Action: $value for plan ${plan.name}',
                        );
                        if (value == 'edit') {
                          _showPlanFormDialog(context, plan: plan);
                        } else if (value == 'toggle') {
                          context.read<SaasPlanBloc>().add(
                            TogglePlanStatus(id: plan.id, isActive: !isActive),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Plan'),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            isActive ? 'Deactivate' : 'Activate',
                            style: TextStyle(
                              color: isActive ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${plan.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: isActive ? const Color(0xFF0F172A) : Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 4),
                      child: Text(
                        '/mo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF64748B)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.isUnlimited
                      ? 'Unlimited Monthly Limit'
                      : 'Up to ৳${plan.monthlyPaymentLimit} limit',
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? const Color(0xFF64748B)
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isActive ? const Color(0xFFE2E8F0) : Colors.grey.shade200,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView.separated(
                itemCount: plan.features.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isActive
                            ? const Color(0xFF7C3AED)
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          plan.features[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: isActive
                                ? const Color(0xFF334155)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanFormDialog extends StatefulWidget {
  final SaasPlanEntity? plan;

  const _PlanFormDialog({this.plan});

  @override
  State<_PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends State<_PlanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _limitController = TextEditingController();

  List<TextEditingController> _featureControllers = [];

  bool get _isEdit => widget.plan != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.plan!.name;
      _priceController.text = widget.plan!.price.toString();
      _limitController.text = widget.plan!.monthlyPaymentLimit.toString();
      for (final f in widget.plan!.features) {
        _featureControllers.add(TextEditingController(text: f));
      }
    } else {
      _featureControllers.add(TextEditingController());
      _limitController.text = '-1';
      _priceController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _limitController.dispose();
    for (var c in _featureControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addFeature() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeature(int index) {
    setState(() {
      _featureControllers[index].dispose();
      _featureControllers.removeAt(index);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final features = _featureControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final event = _isEdit
          ? UpdatePlan(
              id: widget.plan!.id,
              name: _nameController.text.trim(),
              price: double.tryParse(_priceController.text) ?? 0,
              monthlyPaymentLimit: int.tryParse(_limitController.text) ?? -1,
              features: features,
              isActive: widget.plan!.isActive,
              onSuccess: () {
                debugPrint('✅ [UI] Plan update success');
                Navigator.pop(context);
              },
            )
          : CreatePlan(
              name: _nameController.text.trim(),
              price: double.tryParse(_priceController.text) ?? 0,
              monthlyPaymentLimit: int.tryParse(_limitController.text) ?? -1,
              features: features,
              onSuccess: () {
                debugPrint('✅ [UI] Plan creation success');
                Navigator.pop(context);
              },
            );

      debugPrint(
        '🖱️ [UI] Clicking "Save Plan" (Mode: ${_isEdit ? 'Edit' : 'Create'})',
      );
      context.read<SaasPlanBloc>().add(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit ? 'Edit Plan' : 'Add New Plan',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Plan Name',
                          hintText: 'e.g. Pro Plan',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price (৳)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _limitController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Monthly Limit',
                                hintText: '-1 for Unlimited',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Features',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addFeature,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 18,
                            ),
                            label: const Text('Add Feature'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _featureControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _featureControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'e.g. Unlimited API Calls',
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _removeFeature(index),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  splashRadius: 24,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
