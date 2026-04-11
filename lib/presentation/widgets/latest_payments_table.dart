import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';

class LatestPaymentsTable extends StatelessWidget {
  final List<PaymentEntity> payments;

  const LatestPaymentsTable({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Latest Payments",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 40,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF8FAFC),
              ),
              columns: const [
                DataColumn(label: Text("Customer Email")),
                DataColumn(label: Text("Gateway")),
                DataColumn(label: Text("Amount")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Status")),
              ],
              rows: payments.map((payment) {
                return DataRow(
                  cells: [
                    DataCell(Text(payment.customerEmail)),
                    DataCell(Text(payment.gateway)),
                    DataCell(Text("৳${payment.amount.toStringAsFixed(2)}")),
                    DataCell(
                      Text(
                        DateFormat('MMM dd, yyyy').format(payment.createdAt),
                      ),
                    ),
                    DataCell(_buildStatusBadge(payment.status)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
