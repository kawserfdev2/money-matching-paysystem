import 'package:equatable/equatable.dart';

class PaymentLinkEntity extends Equatable {
  final String id;
  final String slug;
  final String productName;
  final String? description;
  final double amount;
  final String currency;
  final DateTime? expiryDate;
  final String? redirectUrl;
  final int? stockLimit;
  final int totalSales;
  final bool isActive;
  final bool isSandbox;
  final DateTime createdAt;

  const PaymentLinkEntity({
    required this.id,
    required this.slug,
    required this.productName,
    this.description,
    required this.amount,
    required this.currency,
    this.expiryDate,
    this.redirectUrl,
    this.stockLimit,
    this.totalSales = 0,
    this.isActive = true,
    this.isSandbox = false,
    required this.createdAt,
  });

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isAvailable =>
      isActive &&
      !isExpired &&
      (stockLimit == null || totalSales < stockLimit!);

  @override
  List<Object?> get props => [
    id,
    slug,
    productName,
    description,
    amount,
    currency,
    expiryDate,
    redirectUrl,
    stockLimit,
    totalSales,
    isActive,
    isSandbox,
    createdAt,
  ];
}
