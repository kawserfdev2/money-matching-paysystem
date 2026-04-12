import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/injection.dart';
import '../../logic/payment/payment_bloc.dart';
import '../../logic/payment/payment_event.dart';
import '../../logic/payment/payment_state.dart';
import '../../domain/repositories/payment_repository.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_table.dart';

class PaymentListPage extends StatefulWidget {
  const PaymentListPage({super.key});

  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'All',
    'Completed',
    'Pending',
    'Failed',
    'Refunded',
    'Canceled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PaymentBloc>()..add(const LoadPayments()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Transactions",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Status Tabs
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    return TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: const Color(0xFF2563EB),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF2563EB),
                      onTap: (index) {
                        context.read<PaymentBloc>().add(
                          FilterByStatus(_tabs[index]),
                        );
                      },
                      tabs: _tabs.map((t) => Tab(text: t)).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Filter Bar
              BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  return TransactionFilterBar(
                    onSearch: (q) =>
                        context.read<PaymentBloc>().add(SearchPayments(q)),
                    onGatewayChanged: (g) => context.read<PaymentBloc>().add(
                      ApplyAdvancedFilters(gateway: g),
                    ),
                    onDateRangeChanged: (r) => context.read<PaymentBloc>().add(
                      ApplyAdvancedFilters(
                        dateRange: r != null
                            ? PaymentDateRange(start: r.start, end: r.end)
                            : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Table Content
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, state) {
                      if (state is PaymentLoading && state.isFirstLoad) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is PaymentLoaded) {
                        return TransactionTable(
                          payments: state.payments,
                          hasReachedMax: state.hasReachedMax,
                          isLoading: state is PaymentLoading,
                          onNextPage: () =>
                              context.read<PaymentBloc>().add(LoadNextPage()),
                        );
                      }

                      if (state is PaymentError) {
                        return Center(child: Text("Error: ${state.message}"));
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
