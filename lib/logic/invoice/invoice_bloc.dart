import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../presentation/services/invoice_pdf_service.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';
import 'dart:math';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository _invoiceRepository;

  InvoiceBloc(this._invoiceRepository) : super(InvoiceInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<InitializeNewInvoice>(_onInitializeNewInvoice);
    on<AddInvoiceItem>(_onAddInvoiceItem);
    on<RemoveInvoiceItem>(_onRemoveInvoiceItem);
    on<UpdateInvoiceItem>(_onUpdateInvoiceItem);
    on<UpdateInvoiceHeader>(_onUpdateInvoiceHeader);
    on<SaveInvoice>(_onSaveInvoice);
    on<GenerateInvoicePDF>(_onGeneratePDF);
  }

  Future<void> _onLoadInvoices(
    LoadInvoices event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoading());
    try {
      final invoices = await _invoiceRepository.getInvoices(
        page: 0,
        pageSize: 50,
        status: event.status,
      );
      emit(InvoiceListLoaded(invoices: invoices, currentStatus: event.status));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  void _onInitializeNewInvoice(
    InitializeNewInvoice event,
    Emitter<InvoiceState> emit,
  ) {
    emit(
      InvoiceFormState(
        dueDate: DateTime.now().add(const Duration(days: 7)),
        items: const [
          InvoiceItemEntity(
            id: 'tmp_0',
            description: '',
            quantity: 1,
            unitPrice: 0.0,
            total: 0.0,
          ),
        ],
      ),
    );
  }

  void _onAddInvoiceItem(AddInvoiceItem event, Emitter<InvoiceState> emit) {
    if (state is InvoiceFormState) {
      final currentState = state as InvoiceFormState;
      final newItems = List<InvoiceItemEntity>.from(currentState.items)
        ..add(
          InvoiceItemEntity(
            id: 'tmp_${Random().nextInt(10000)}',
            description: '',
            quantity: 1,
            unitPrice: 0.0,
            total: 0.0,
          ),
        );

      emit(_calculateTotals(currentState.copyWith(items: newItems)));
    }
  }

  void _onRemoveInvoiceItem(
    RemoveInvoiceItem event,
    Emitter<InvoiceState> emit,
  ) {
    if (state is InvoiceFormState) {
      final currentState = state as InvoiceFormState;
      if (currentState.items.length > 1) {
        final newItems = List<InvoiceItemEntity>.from(currentState.items)
          ..removeAt(event.index);
        emit(_calculateTotals(currentState.copyWith(items: newItems)));
      }
    }
  }

  void _onUpdateInvoiceItem(
    UpdateInvoiceItem event,
    Emitter<InvoiceState> emit,
  ) {
    if (state is InvoiceFormState) {
      final currentState = state as InvoiceFormState;
      final items = List<InvoiceItemEntity>.from(currentState.items);
      final item = items[event.index];

      final qty = event.quantity ?? item.quantity;
      final price = event.unitPrice ?? item.unitPrice;
      final disc = event.discountPercent ?? item.discountPercent;
      final vat = event.vatPercent ?? item.vatPercent;

      // Calculate single item total
      final baseTotal = qty * price;
      final discountValue = baseTotal * (disc / 100);
      final vatValue = (baseTotal - discountValue) * (vat / 100);
      final total = baseTotal - discountValue + vatValue;

      items[event.index] = InvoiceItemEntity(
        id: item.id,
        description: event.description ?? item.description,
        quantity: qty,
        unitPrice: price,
        discountPercent: disc,
        vatPercent: vat,
        total: double.parse(total.toStringAsFixed(2)),
      );

      emit(_calculateTotals(currentState.copyWith(items: items)));
    }
  }

  void _onUpdateInvoiceHeader(
    UpdateInvoiceHeader event,
    Emitter<InvoiceState> emit,
  ) {
    if (state is InvoiceFormState) {
      final currentState = state as InvoiceFormState;
      final newState = currentState.copyWith(
        customerId: event.customerId,
        currency: event.currency,
        dueDate: event.dueDate,
        status: event.status,
        shippingCharge: event.shippingCharge,
        notes: event.notes,
        redirectUrl: event.redirectUrl,
      );
      emit(_calculateTotals(newState));
    }
  }

  InvoiceFormState _calculateTotals(InvoiceFormState state) {
    double subtotal = 0.0;
    double totalDiscount = 0.0;
    double totalVat = 0.0;

    for (var item in state.items) {
      final itemBase = item.quantity * item.unitPrice;
      final itemDisc = itemBase * (item.discountPercent / 100);
      final itemVat = (itemBase - itemDisc) * (item.vatPercent / 100);

      subtotal += itemBase;
      totalDiscount += itemDisc;
      totalVat += itemVat;
    }

    final grandTotal =
        subtotal - totalDiscount + totalVat + state.shippingCharge;

    return state.copyWith(
      subtotal: double.parse(subtotal.toStringAsFixed(2)),
      totalDiscount: double.parse(totalDiscount.toStringAsFixed(2)),
      totalVat: double.parse(totalVat.toStringAsFixed(2)),
      grandTotal: double.parse(grandTotal.toStringAsFixed(2)),
    );
  }

  Future<void> _onSaveInvoice(
    SaveInvoice event,
    Emitter<InvoiceState> emit,
  ) async {
    if (state is InvoiceFormState) {
      final s = state as InvoiceFormState;
      if (s.customerId.isEmpty) {
        emit(s.copyWith(error: 'Please select a customer'));
        return;
      }

      emit(s.copyWith(isSaving: true));
      try {
        final invoice = InvoiceEntity(
          id: '',
          invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
          customerId: s.customerId,
          totalAmount: s.grandTotal,
          currency: s.currency,
          dueDate: s.dueDate,
          status: s.status,
          shippingCharge: s.shippingCharge,
          notes: s.notes,
          redirectUrl: s.redirectUrl,
          createdAt: DateTime.now(),
          items: s.items,
        );

        await _invoiceRepository.saveInvoice(invoice);
        emit(InvoiceSavedSuccess());
        add(const LoadInvoices());
      } catch (e) {
        emit(s.copyWith(isSaving: false, error: e.toString()));
      }
    }
  }

  Future<void> _onGeneratePDF(
    GenerateInvoicePDF event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      // In a cleaner architecture, we'd emit a state and let the UI call the service,
      // but for this implementation we'll call the service directly.
      await InvoicePDFService.generateAndPrint(event.invoice);
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }
}
