import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice_entity.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceListLoaded extends InvoiceState {
  final List<InvoiceEntity> invoices;
  final String currentStatus;
  final bool hasReachedMax;

  const InvoiceListLoaded({
    required this.invoices,
    this.currentStatus = 'All',
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [invoices, currentStatus, hasReachedMax];
}

class InvoiceFormState extends InvoiceState {
  final String customerId;
  final String currency;
  final DateTime dueDate;
  final String status;
  final double shippingCharge;
  final String notes;
  final String redirectUrl;
  final List<InvoiceItemEntity> items;

  // Calculated Totals
  final double subtotal;
  final double totalDiscount;
  final double totalVat;
  final double grandTotal;

  // UI States
  final bool isSaving;
  final String? error;

  const InvoiceFormState({
    this.customerId = '',
    this.currency = 'BDT',
    required this.dueDate,
    this.status = 'unpaid',
    this.shippingCharge = 0.0,
    this.notes = '',
    this.redirectUrl = '',
    this.items = const [],
    this.subtotal = 0.0,
    this.totalDiscount = 0.0,
    this.totalVat = 0.0,
    this.grandTotal = 0.0,
    this.isSaving = false,
    this.error,
  });

  InvoiceFormState copyWith({
    String? customerId,
    String? currency,
    DateTime? dueDate,
    String? status,
    double? shippingCharge,
    String? notes,
    String? redirectUrl,
    List<InvoiceItemEntity>? items,
    double? subtotal,
    double? totalDiscount,
    double? totalVat,
    double? grandTotal,
    bool? isSaving,
    String? error,
  }) {
    return InvoiceFormState(
      customerId: customerId ?? this.customerId,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      shippingCharge: shippingCharge ?? this.shippingCharge,
      notes: notes ?? this.notes,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      totalVat: totalVat ?? this.totalVat,
      grandTotal: grandTotal ?? this.grandTotal,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    customerId,
    currency,
    dueDate,
    status,
    shippingCharge,
    notes,
    redirectUrl,
    items,
    subtotal,
    totalDiscount,
    totalVat,
    grandTotal,
    isSaving,
    error,
  ];
}

class InvoiceSavedSuccess extends InvoiceState {}

class InvoicePDFGenerated extends InvoiceState {
  final Uint8List pdfData;
  final String fileName;

  const InvoicePDFGenerated(this.pdfData, this.fileName);

  @override
  List<Object?> get props => [pdfData, fileName];
}

class InvoiceError extends InvoiceState {
  final String message;
  const InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}
