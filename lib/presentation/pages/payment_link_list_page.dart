import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/injection.dart';
import '../../logic/payment_link/payment_link_bloc.dart';
import '../../logic/payment_link/payment_link_event.dart';
import '../../logic/payment_link/payment_link_state.dart';
import '../../domain/entities/payment_link_entity.dart';
import '../widgets/payment_link_form_drawer.dart';

class PaymentLinkListPage extends StatelessWidget {
  const PaymentLinkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PaymentLinkBloc>()..add(LoadPaymentLinks()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: BlocListener<PaymentLinkBloc, PaymentLinkState>(
          listener: (context, state) {
            if (state is PaymentLinkActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is PaymentLinkError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Payment Links",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openCreateForm(context),
                          icon: const Icon(Icons.add),
                          label: const Text("Create New Link"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Links Table
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: BlocBuilder<PaymentLinkBloc, PaymentLinkState>(
                          builder: (context, state) {
                            if (state is PaymentLinkLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is PaymentLinkLoaded) {
                              return _buildTable(context, state.links);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<PaymentLinkEntity> links) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1000,
      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
      columns: const [
        DataColumn2(label: Text('Product Name'), size: ColumnSize.L),
        DataColumn2(label: Text('Price'), size: ColumnSize.M),
        DataColumn2(label: Text('Sales'), size: ColumnSize.S),
        DataColumn2(label: Text('Created'), size: ColumnSize.M),
        DataColumn2(label: Text('Status'), size: ColumnSize.S),
        DataColumn2(label: Text('Actions'), size: ColumnSize.M),
      ],
      rows: links.map((link) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                link.productName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(Text("${link.currency} ${link.amount}")),
            DataCell(Text(link.totalSales.toString())),
            DataCell(Text(DateFormat('MMM dd, yyyy').format(link.createdAt))),
            DataCell(_buildStatusChip(link)),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyLink(context, link.slug),
                    tooltip: "Copy Link",
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.qr_code,
                      size: 20,
                      color: Colors.blue,
                    ),
                    onPressed: () => _showQR(context, link),
                    tooltip: "Show QR",
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => _confirmDelete(context, link.id),
                    tooltip: "Delete",
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusChip(PaymentLinkEntity link) {
    final bool active = link.isActive && !link.isExpired;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        active ? "Active" : "Inactive",
        style: TextStyle(
          color: active ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _copyLink(BuildContext context, String slug) {
    // In a real app, use the actual domain.
    final url = "https://amarpay.com/pay/$slug";
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Link copied to clipboard!")));
  }

  void _showQR(BuildContext context, PaymentLinkEntity link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(link.productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: "https://amarpay.com/pay/${link.slug}",
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "https://amarpay.com/pay/${link.slug}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () => _copyLink(context, link.slug),
            child: const Text("Copy Link"),
          ),
        ],
      ),
    );
  }

  void _openCreateForm(BuildContext context) {
    final bloc = context.read<PaymentLinkBloc>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Create Link",
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: PaymentLinkFormDrawer(
            onSave: (link) {
              bloc.add(CreatePaymentLink(link));
              Navigator.pop(context);
            },
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final bloc = context.read<PaymentLinkBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Link"),
        content: const Text(
          "Are you sure you want to delete this payment link?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeletePaymentLink(id));
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
