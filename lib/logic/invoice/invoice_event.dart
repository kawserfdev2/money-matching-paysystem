import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice_entity.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoices extends InvoiceEvent {
  final bool isRefresh;
  final String status;
  const LoadInvoices({this.isRefresh = false, this.status = 'All'});

  @override
  List<Object?> get props => [isRefresh, status];
}

class InitializeNewInvoice extends InvoiceEvent {}

class AddInvoiceItem extends InvoiceEvent {}

class RemoveInvoiceItem extends InvoiceEvent {
  final int index;
  const RemoveInvoiceItem(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateInvoiceItem extends InvoiceEvent {
  final int index;
  final String? description;
  final int? quantity;
  final double? unitPrice;
  final double? discountPercent;
  final double? vatPercent;

  const UpdateInvoiceItem({
    required this.index,
    this.description,
    this.quantity,
    this.unitPrice,
    this.discountPercent,
    this.vatPercent,
  });

  @override
  List<Object?> get props => [
    index,
    description,
    quantity,
    unitPrice,
    discountPercent,
    vatPercent,
  ];
}

class UpdateInvoiceHeader extends InvoiceEvent {
  final String? customerId;
  final String? currency;
  final DateTime? dueDate;
  final String? status;
  final double? shippingCharge;
  final String? notes;
  final String? redirectUrl;

  const UpdateInvoiceHeader({
    this.customerId,
    this.currency,
    this.dueDate,
    this.status,
    this.shippingCharge,
    this.notes,
    this.redirectUrl,
  });

  @override
  List<Object?> get props => [
    customerId,
    currency,
    dueDate,
    status,
    shippingCharge,
    notes,
    redirectUrl,
  ];
}

class SaveInvoice extends InvoiceEvent {}

class GenerateInvoicePDF extends InvoiceEvent {
  final InvoiceEntity invoice;
  const GenerateInvoicePDF(this.invoice);

  @override
  List<Object?> get props => [invoice];
}
