import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.customerEmail,
    required super.gateway,
    required super.amount,
    required super.createdAt,
    required super.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      customerEmail: json['customer_email'] as String? ?? 'N/A',
      gateway: json['gateway'] as String? ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }
}
