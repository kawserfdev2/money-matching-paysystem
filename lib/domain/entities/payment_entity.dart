import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String customerEmail;
  final String gateway;
  final double amount;
  final DateTime createdAt;
  final String status;

  const PaymentEntity({
    required this.id,
    required this.customerEmail,
    required this.gateway,
    required this.amount,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    customerEmail,
    gateway,
    amount,
    createdAt,
    status,
  ];
}
