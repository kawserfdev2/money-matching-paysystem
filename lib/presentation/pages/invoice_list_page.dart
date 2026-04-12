import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/injection.dart';
import '../../logic/invoice/invoice_bloc.dart';
import '../../logic/invoice/invoice_event.dart';
import '../../logic/invoice/invoice_state.dart';
import '../../domain/entities/invoice_entity.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Paid', 'Unpaid', 'Partial', 'Canceled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      context.read<InvoiceBloc>().add(
        LoadInvoices(status: _tabs[_tabController.index]),
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InvoiceBloc>()..add(const LoadInvoices()),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Billing & Invoices",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/invoices/create'),
                    icon: const Icon(Icons.add),
                    label: const Text("Create Invoice"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Tabs
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Invoice Table
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: BlocBuilder<InvoiceBloc, InvoiceState>(
                    builder: (context, state) {
                      if (state is InvoiceLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is InvoiceListLoaded) {
                        return _buildTable(context, state.invoices);
                      }

                      if (state is InvoiceError) {
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

  Widget _buildTable(BuildContext context, List<InvoiceEntity> invoices) {
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 2);

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 800,
      headingRowColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      columns: const [
        DataColumn2(label: Text('Invoice ID'), size: ColumnSize.M),
        DataColumn2(label: Text('Customer'), size: ColumnSize.L),
        DataColumn2(label: Text('Due Date')),
        DataColumn2(label: Text('Amount')),
        DataColumn2(label: Text('Status')),
        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
      ],
      rows: invoices.map((invoice) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                invoice.invoiceNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataCell(Text(invoice.customerName ?? 'Unknown')),
            DataCell(Text(DateFormat('MMM dd, yyyy').format(invoice.dueDate))),
            DataCell(Text(currencyFormat.format(invoice.totalAmount))),
            DataCell(_buildStatusBadge(invoice.status)),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.download_rounded,
                      size: 20,
                      color: Colors.blue,
                    ),
                    onPressed: () => _downloadPDF(context, invoice),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                    onPressed: () => _viewDetails(context, invoice),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'unpaid':
        color = Colors.orange;
        break;
      case 'partial':
        color = Colors.blue;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _downloadPDF(BuildContext context, InvoiceEntity invoice) {
    context.read<InvoiceBloc>().add(GenerateInvoicePDF(invoice));
  }

  void _viewDetails(BuildContext context, InvoiceEntity invoice) {
    // Navigate to details or open side drawer
  }
}
