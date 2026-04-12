import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.customerEmail,
    required super.gateway,
    required super.amount,
    required super.netAmount,
    required super.transactionId,
    required super.createdAt,
    required super.status,
    required super.currency,
    super.ipAddress,
    super.userAgent,
    super.gatewayResponse,
    super.metadata,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> meta =
        json['metadata'] as Map<String, dynamic>? ?? {};
    return PaymentModel(
      id: json['id'] as String,
      customerEmail: json['customer_email'] as String? ?? 'N/A',
      gateway: json['gateway'] as String? ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      transactionId: json['transaction_id'] as String? ?? json['id'],
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'pending',
      currency: json['currency'] as String? ?? 'BDT',
      ipAddress: meta['ip_address'] as String?,
      userAgent: meta['user_agent'] as String?,
      gatewayResponse: meta['gateway_response'] as Map<String, dynamic>?,
      metadata: meta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_email': customerEmail,
      'gateway': gateway,
      'amount': amount,
      'net_amount': netAmount,
      'transaction_id': transactionId,
      'status': status,
      'currency': currency,
      'metadata': {
        ...?metadata,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'gateway_response': gatewayResponse,
      },
    };
  }
}
