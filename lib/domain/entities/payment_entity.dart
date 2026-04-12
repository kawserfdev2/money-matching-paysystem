import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String customerEmail;
  final String gateway;
  final double amount;
  final double netAmount;
  final String transactionId;
  final DateTime createdAt;
  final String status;
  final String currency;

  // Metadata for Detailed View
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? gatewayResponse;
  final Map<String, dynamic>? metadata;

  const PaymentEntity({
    required this.id,
    required this.customerEmail,
    required this.gateway,
    required this.amount,
    required this.netAmount,
    required this.transactionId,
    required this.createdAt,
    required this.status,
    this.currency = 'BDT',
    this.ipAddress,
    this.userAgent,
    this.gatewayResponse,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    customerEmail,
    gateway,
    amount,
    netAmount,
    transactionId,
    createdAt,
    status,
    currency,
    ipAddress,
    userAgent,
    gatewayResponse,
    metadata,
  ];
}
