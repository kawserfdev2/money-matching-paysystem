import 'package:amarpay/logic/superadmin/saas_plan/saas_plan_state.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/injection.dart';
import '../../../domain/entities/subscription_detail_entity.dart';
import '../../../logic/superadmin/saas_plan/saas_plan_bloc.dart';
import '../../../logic/superadmin/saas_plan/saas_plan_event.dart';
import '../../../logic/superadmin/subscription/subscription_bloc.dart';
import '../../../logic/superadmin/subscription/subscription_event.dart';
import '../../../logic/superadmin/subscription/subscription_state.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SubscriptionBloc>()..add(const LoadSubscriptions()),
      child: const _SubscriptionsView(),
    );
  }
}

class _SubscriptionsView extends StatelessWidget {
  const _SubscriptionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Merchant Subscriptions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            const _FilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  builder: (context, state) {
                    if (state is SubscriptionLoading ||
                        state is SubscriptionInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SubscriptionError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (state is SubscriptionLoaded) {
                      return _SubscriptionsTable(
                        subscriptions: state.subscriptions,
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Active', 'value': 'active'},
      {'label': 'Expiring Soon', 'value': 'expiring_soon'},
      {'label': 'Overdue', 'value': 'overdue'},
      {'label': 'Canceled', 'value': 'canceled'},
      {'label': 'Trial', 'value': 'trial'},
    ];

    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        String currentFilter = 'all';
        if (state is SubscriptionLoaded) {
          currentFilter = state.currentFilter;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final isSelected = currentFilter == filter['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  selectedColor: const Color(0xFF7C3AED).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF64748B),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      debugPrint(
                        '🖱️ [UI] Subscription Filter changed to: ${filter['value']}',
                      );
                      context.read<SubscriptionBloc>().add(
                        FilterSubscriptions(filter['value']!),
                      );
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SubscriptionsTable extends StatelessWidget {
  final List<SubscriptionDetailEntity> subscriptions;

  const _SubscriptionsTable({required this.subscriptions});

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const Center(
        child: Text(
          'No subscriptions found for this filter.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 24,
      headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF475569),
      ),
      columns: const [
        DataColumn2(label: Text('MERCHANT'), size: ColumnSize.L),
        DataColumn2(label: Text('CURRENT PLAN'), size: ColumnSize.L),
        DataColumn2(label: Text('START DATE'), size: ColumnSize.M),
        DataColumn2(label: Text('EXPIRY DATE'), size: ColumnSize.M),
        DataColumn2(label: Text('STATUS'), size: ColumnSize.S),
        DataColumn2(
          label: Text('ACTIONS'),
          size: ColumnSize.S,
          fixedWidth: 100,
        ),
      ],
      rows: subscriptions.map((sub) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                sub.brandName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            DataCell(
              Row(
                children: [
                  Text(
                    sub.planName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sub.billingCycle.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                DateFormat('dd MMM yyyy').format(sub.startDate),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            DataCell(
              Text(
                DateFormat('dd MMM yyyy').format(sub.endDate),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            DataCell(_StatusBadge(status: sub.status)),
            DataCell(
              IconButton(
                icon: const Icon(Icons.edit_calendar, color: Color(0xFF7C3AED)),
                onPressed: () {
                  debugPrint(
                    '🖱️ [UI] Clicking Manage Subscription for: ${sub.brandName}',
                  );
                  final bloc = context.read<SubscriptionBloc>();
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: bloc),
                          BlocProvider(
                            create: (context) => getIt<SaasPlanBloc>()
                              ..add(const LoadPlans(includeInactive: false)),
                          ),
                        ],
                        child: _ManageSubscriptionDialog(subscription: sub),
                      );
                    },
                  );
                },
                tooltip: 'Manage Subscription',
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'active':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case 'overdue':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        break;
      case 'trial':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case 'canceled':
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

// ============================================

class _ManageSubscriptionDialog extends StatefulWidget {
  final SubscriptionDetailEntity subscription;

  const _ManageSubscriptionDialog({required this.subscription});

  @override
  State<_ManageSubscriptionDialog> createState() =>
      _ManageSubscriptionDialogState();
}

class _ManageSubscriptionDialogState extends State<_ManageSubscriptionDialog> {
  DateTime? _selectedDate;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.subscription.endDate;
    _selectedPlanId = widget.subscription.planId;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    debugPrint(
      '🖱️ [UI] Saving Subscription Override (PlanID: $_selectedPlanId, EndDate: $_selectedDate)',
    );
    context.read<SubscriptionBloc>().add(
      ManualOverrideSubscription(
        id: widget.subscription.id,
        newPlanId: _selectedPlanId != widget.subscription.planId
            ? _selectedPlanId
            : null,
        newEndDate: _selectedDate != widget.subscription.endDate
            ? _selectedDate
            : null,
        onSuccess: () {
          debugPrint('✅ [UI] Subscription override success');
          Navigator.pop(context);
        },
        onError: (err) {
          debugPrint('❌ [UI] Subscription override error: $err');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Subscription',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Brand: ${widget.subscription.brandName}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Override Plan
            const Text(
              'Change Plan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            BlocBuilder<SaasPlanBloc, SaasPlanState>(
              builder: (context, state) {
                if (state is PlanLoading || state is PlanInitial) {
                  return const LinearProgressIndicator();
                }
                if (state is PlanLoaded) {
                  return DropdownButtonFormField<String>(
                    value: _selectedPlanId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: state.plans.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.name} (৳${p.price})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedPlanId = val;
                      });
                    },
                  );
                }
                return const Text(
                  'Failed to load plans',
                  style: TextStyle(color: Colors.red),
                );
              },
            ),
            const SizedBox(height: 24),

            // Override Date
            const Text(
              'Extend/Modify End Date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                          : 'Select Date',
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
