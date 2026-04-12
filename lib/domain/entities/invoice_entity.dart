import 'package:equatable/equatable.dart';

class InvoiceItemEntity extends Equatable {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double discountPercent;
  final double vatPercent;
  final double total;

  const InvoiceItemEntity({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0.0,
    this.vatPercent = 0.0,
    required this.total,
  });

  @override
  List<Object?> get props => [
    id,
    description,
    quantity,
    unitPrice,
    discountPercent,
    vatPercent,
    total,
  ];
}

class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String? customerName; // Optional for list view optimization
  final double totalAmount;
  final String currency;
  final DateTime dueDate;
  final String status; // 'paid', 'unpaid', 'partial', 'canceled'
  final double shippingCharge;
  final String? notes;
  final String? redirectUrl;
  final DateTime createdAt;
  final List<InvoiceItemEntity> items;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    this.customerName,
    required this.totalAmount,
    required this.currency,
    required this.dueDate,
    required this.status,
    this.shippingCharge = 0.0,
    this.notes,
    this.redirectUrl,
    required this.createdAt,
    this.items = const [],
  });

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    customerId,
    customerName,
    totalAmount,
    currency,
    dueDate,
    status,
    shippingCharge,
    notes,
    redirectUrl,
    createdAt,
    items,
  ];
}
