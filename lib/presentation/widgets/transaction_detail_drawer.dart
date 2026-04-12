import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment_entity.dart';

class TransactionDetailDrawer extends StatelessWidget {
  final PaymentEntity payment;

  const TransactionDetailDrawer({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '৳ ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Drawer(
      width: 450,
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Payment Information"),
                  _buildInfoRow(
                    "Transaction ID",
                    payment.transactionId,
                    isCopyable: true,
                  ),
                  _buildInfoRow(
                    "Status",
                    payment.status.toUpperCase(),
                    isStatus: true,
                  ),
                  _buildInfoRow(
                    "Date & Time",
                    dateFormat.format(payment.createdAt),
                  ),
                  _buildInfoRow(
                    "Gateway",
                    payment.gateway.replaceAll('_', ' ').toUpperCase(),
                  ),
                  const Divider(height: 32),

                  _buildSectionTitle("Financial Breakdown"),
                  _buildInfoRow(
                    "Gross Amount",
                    currencyFormat.format(payment.amount),
                  ),
                  _buildInfoRow(
                    "Net Amount",
                    currencyFormat.format(payment.netAmount),
                    isBold: true,
                  ),
                  const Divider(height: 32),

                  _buildSectionTitle("Customer Details"),
                  _buildInfoRow("Email", payment.customerEmail),
                  _buildInfoRow("IP Address", payment.ipAddress ?? 'N/A'),
                  _buildInfoRow(
                    "User Agent",
                    payment.userAgent ?? 'N/A',
                    isSmall: true,
                  ),
                  const Divider(height: 32),

                  _buildSectionTitle("Gateway Response"),
                  _buildJsonResponse(payment.gatewayResponse),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: const Color(0xFFF8FAFC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Transaction Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isBold = false,
    bool isCopyable = false,
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      fontSize: isSmall ? 12 : 13,
                      color: isStatus ? _getStatusColor(value) : Colors.black,
                    ),
                  ),
                ),
                if (isCopyable)
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.copy, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonResponse(Map<String, dynamic>? response) {
    if (response == null || response.isEmpty)
      return const Text(
        "No gateway data available",
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        response.toString(),
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
