import '../../domain/entities/invoice_entity.dart';

class InvoiceItemModel extends InvoiceItemEntity {
  const InvoiceItemModel({
    required super.id,
    required super.description,
    required super.quantity,
    required super.unitPrice,
    super.discountPercent = 0.0,
    super.vatPercent = 0.0,
    required super.total,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
      vatPercent: (json['vat_percent'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_percent': discountPercent,
      'vat_percent': vatPercent,
      'total': total,
    };
  }
}

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.customerId,
    super.customerName,
    required super.totalAmount,
    required super.currency,
    required super.dueDate,
    required super.status,
    super.shippingCharge = 0.0,
    super.notes,
    super.redirectUrl,
    required super.createdAt,
    super.items = const [],
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    // Handle customer join if available
    String? customerName;
    if (json['customers'] != null) {
      customerName =
          "${json['customers']['first_name']} ${json['customers']['last_name'] ?? ""}"
              .trim();
    }

    return InvoiceModel(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      customerId: json['customer_id'],
      customerName: customerName,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      currency: json['currency'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      shippingCharge: (json['shipping_charge'] ?? 0).toDouble(),
      notes: json['notes'],
      redirectUrl: json['redirect_url'],
      createdAt: DateTime.parse(json['created_at']),
      items:
          (json['invoice_items'] as List?)
              ?.map((i) => InvoiceItemModel.fromJson(i))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'currency': currency,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'status': status,
      'shipping_charge': shippingCharge,
      'notes': notes,
      'redirect_url': redirectUrl,
      'total_amount': totalAmount,
    };
  }
}
