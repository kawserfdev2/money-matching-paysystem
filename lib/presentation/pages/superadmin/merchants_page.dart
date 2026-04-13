import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../logic/superadmin/merchant_bloc.dart';
import '../../../logic/superadmin/merchant_event.dart';
import '../../../logic/superadmin/merchant_state.dart';
import '../../../data/models/superadmin/merchant_summary_model.dart';
import '../../../core/injection.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';

class MerchantManagementPage extends StatelessWidget {
  const MerchantManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MerchantManagementBloc>()..add(LoadMerchants()),
      child: const _MerchantsView(),
    );
  }
}

class _MerchantsView extends StatefulWidget {
  const _MerchantsView();

  @override
  State<_MerchantsView> createState() => _MerchantsViewState();
}

class _MerchantsViewState extends State<_MerchantsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Merchant Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                BlocBuilder<MerchantManagementBloc, MerchantState>(
                  builder: (context, state) {
                    if (state is MerchantLoaded) {
                      return Text(
                        '${state.merchants.length} merchants',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Search & Filter Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) {
                      debugPrint('🔍 [UI] Superadmin searching merchants: $v');
                      context.read<MerchantManagementBloc>().add(
                        SearchMerchants(v),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by brand or email...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Status Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      icon: const Icon(
                        Icons.filter_list_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'suspended',
                          child: Text('Suspended'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        debugPrint(
                          '🖱️ [UI] Merchant Status Filter changed to: $v',
                        );
                        setState(() => _selectedStatus = v);
                        context.read<MerchantManagementBloc>().add(
                          FilterMerchants(v),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                  onPressed: () {
                    debugPrint('🖱️ [UI] Refreshing merchant list');
                    context.read<MerchantManagementBloc>().add(
                      LoadMerchants(isRefresh: true),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Table Area
            Expanded(
              child: BlocBuilder<MerchantManagementBloc, MerchantState>(
                builder: (context, state) {
                  if (state is MerchantLoading || state is MerchantInitial) {
                    return const _MerchantTableShimmer();
                  }

                  if (state is MerchantError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<MerchantManagementBloc>()
                                .add(LoadMerchants(isRefresh: true)),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MerchantLoaded) {
                    if (state.merchants.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 64,
                              color: Color(0xFFCBD5E1),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No merchants found',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: DataTable2(
                                columnSpacing: 16,
                                horizontalMargin: 20,
                                headingRowHeight: 48,
                                dataRowHeight: 64,
                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFFF8FAFC),
                                ),
                                columns: const [
                                  DataColumn2(
                                    label: Text(
                                      'Brand & Owner',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                      ),
                                    ),
                                    size: ColumnSize.L,
                                  ),
                                  DataColumn2(
                                    label: Text(
                                      'Total Volume',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  DataColumn2(
                                    label: Text(
                                      'Joined',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  DataColumn2(
                                    label: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                      ),
                                    ),
                                    fixedWidth: 110,
                                  ),
                                  DataColumn2(
                                    label: Text(
                                      'Actions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                      ),
                                    ),
                                    fixedWidth: 130,
                                  ),
                                ],
                                rows: state.merchants
                                    .map((m) => _buildRow(context, m))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        // Load More
                        if (!state.hasReachedMax)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextButton.icon(
                              onPressed: () => context
                                  .read<MerchantManagementBloc>()
                                  .add(LoadMoreMerchants()),
                              icon: const Icon(Icons.expand_more_rounded),
                              label: const Text('Load More'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow2 _buildRow(BuildContext context, MerchantSummaryModel m) {
    final initial = m.brandName.isNotEmpty ? m.brandName[0].toUpperCase() : '?';

    return DataRow2(
      cells: [
        // Brand & Owner
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      m.brandName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      m.ownerEmail,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Volume
        DataCell(
          Text(
            '৳${NumberFormat('#,##0.00').format(m.totalProcessedVolume)}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        // Joined Date
        DataCell(
          Text(
            DateFormat('dd MMM yyyy').format(m.joinedDate),
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
        // Status Badge
        DataCell(_StatusBadge(status: m.status)),
        // Actions
        DataCell(
          SelectionContainer.disabled(
            child: Row(
              children: [
                _ActionBtn(
                  icon: Icons.visibility_rounded,
                  color: const Color(0xFF2563EB),
                  tooltip: 'View',
                  onTap: () {
                    debugPrint('View clicked for ${m.brandName}');
                  },
                ),
                _ActionBtn(
                  icon: m.status == 'active'
                      ? Icons.block_rounded
                      : Icons.check_circle_rounded,
                  color: m.status == 'active'
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF059669),
                  tooltip: m.status == 'active' ? 'Suspend' : 'Activate',
                  onTap: () => _showStatusDialog(context, m),
                ),
                _ActionBtn(
                  icon: Icons.login_rounded,
                  color: const Color(0xFF7C3AED),
                  tooltip: 'Login As',
                  onTap: () {
                    debugPrint('Login As clicked for ${m.brandName}');
                    _showImpersonationDialog(context, m);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImpersonationDialog(BuildContext context, MerchantSummaryModel m) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Login as ${m.brandName}?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to view the dashboard as ${m.brandName}? Any changes you make will affect their live account.',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Future.delayed(const Duration(milliseconds: 300), () {
                  // ignore: use_build_context_synchronously
                  if (context.mounted) {
                    context.read<AuthBloc>().add(
                      StartImpersonation(m.merchantId),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Login As'),
            ),
          ],
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context, MerchantSummaryModel m) {
    debugPrint('Opening status dialog for ${m.brandName}');
    final isActive = m.status == 'active';
    final actionText = isActive ? 'Suspend' : 'Activate';
    final color = isActive ? const Color(0xFFEF4444) : const Color(0xFF059669);
    final bloc = context.read<MerchantManagementBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;

        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  '$actionText ${m.brandName}?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  isActive
                      ? 'Are you sure you want to suspend this merchant? They will immediately lose access to their dashboard, and their API keys will stop working.'
                      : 'Are you sure you want to activate this merchant? Their dashboard and API keys will be functional again.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            debugPrint(
                              'Confirming $actionText for ${m.brandName}',
                            );
                            setDialogState(() => isLoading = true);
                            context.read<MerchantManagementBloc>().add(
                              ToggleMerchantStatus(
                                merchantId: m.merchantId,
                                currentStatus: m.status,
                                onSuccess: () {
                                  debugPrint('Toggle status successful');
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${m.brandName} is now ${isActive ? 'suspended' : 'active'}.',
                                      ),
                                      backgroundColor: const Color(0xFF0F172A),
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                onError: (error) {
                                  debugPrint('Toggle status error: $error');
                                  if (!mounted) return;
                                  setDialogState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(actionText),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Suspended',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF166534) : const Color(0xFF991B1B),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint('ActionButton InkWell tapped: $tooltip');
            onTap();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class _MerchantTableShimmer extends StatelessWidget {
  const _MerchantTableShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Column(
        children: List.generate(
          8,
          (i) => Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
