import '../../domain/entities/payment_link_entity.dart';

class PaymentLinkModel extends PaymentLinkEntity {
  const PaymentLinkModel({
    required super.id,
    required super.slug,
    required super.productName,
    super.description,
    required super.amount,
    required super.currency,
    super.expiryDate,
    super.redirectUrl,
    super.stockLimit,
    super.totalSales = 0,
    super.isActive = true,
    super.isSandbox = false,
    required super.createdAt,
  });

  factory PaymentLinkModel.fromJson(Map<String, dynamic> json) {
    return PaymentLinkModel(
      id: json['id'],
      slug: json['slug'],
      productName: json['product_name'],
      description: json['description'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'BDT',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      redirectUrl: json['redirect_url'],
      stockLimit: json['stock_limit'],
      totalSales: json['total_sales'] ?? 0,
      isActive: json['is_active'] ?? true,
      isSandbox: json['is_sandbox'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'product_name': productName,
      'description': description,
      'amount': amount,
      'currency': currency,
      'expiry_date': expiryDate?.toIso8601String(),
      'redirect_url': redirectUrl,
      'stock_limit': stockLimit,
      'is_active': isActive,
      'is_sandbox': isSandbox,
    };
  }
}
