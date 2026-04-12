import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';
import 'transaction_detail_drawer.dart';

class TransactionTable extends StatelessWidget {
  final List<PaymentEntity> payments;
  final bool isLoading;
  final bool hasReachedMax;
  final VoidCallback onNextPage;

  const TransactionTable({
    super.key,
    required this.payments,
    this.isLoading = false,
    required this.hasReachedMax,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '৳ ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Column(
      children: [
        Expanded(
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 1000,
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn2(label: Text('Customer'), size: ColumnSize.L),
              DataColumn2(label: Text('Gateway'), size: ColumnSize.M),
              DataColumn2(label: Text('Amount'), numeric: true),
              DataColumn2(label: Text('Net Amount'), numeric: true),
              DataColumn2(label: Text('Transaction ID'), size: ColumnSize.M),
              DataColumn2(label: Text('Date'), size: ColumnSize.M),
              DataColumn2(label: Text('Status'), size: ColumnSize.S),
              DataColumn2(label: Text('Action'), size: ColumnSize.S),
            ],
            rows: payments.map((payment) {
              return DataRow(
                cells: [
                  DataCell(Text(payment.customerEmail)),
                  DataCell(
                    Text(payment.gateway.replaceAll('_', ' ').toUpperCase()),
                  ),
                  DataCell(Text(currencyFormat.format(payment.amount))),
                  DataCell(Text(currencyFormat.format(payment.netAmount))),
                  DataCell(
                    Text(
                      payment.transactionId,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  DataCell(
                    Text(
                      dateFormat.format(payment.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  DataCell(_buildStatusBadge(payment.status)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 20),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                        // Note: This expects the drawer to be available. We'll handle this in the Page.
                        _showDetails(context, payment);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        if (!hasReachedMax)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: isLoading ? null : onNextPage,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Load More Transactions"),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'failed':
        color = Colors.red;
        break;
      case 'refunded':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
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

  void _showDetails(BuildContext context, PaymentEntity payment) {
    showEndDrawer(context: context, payment: payment);
  }

  static void showEndDrawer({
    required BuildContext context,
    required PaymentEntity payment,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Details",
      pageBuilder: (ctx, anim1, anim2) => Align(
        alignment: Alignment.centerRight,
        child: TransactionDetailDrawer(payment: payment),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(anim1),
        child: child,
      ),
    );
  }
}
