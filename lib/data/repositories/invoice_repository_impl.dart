import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../models/invoice_model.dart';
import '../models/invoice_model.dart' show InvoiceItemModel;

class InvoiceRepositoryImpl implements InvoiceRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<InvoiceEntity>> getInvoices({
    required int page,
    required int pageSize,
    String? status,
    String? searchQuery,
  }) async {
    var query = _supabase
        .from('invoices')
        .select('*, customers(first_name, last_name)');

    if (status != null && status != 'All') {
      query = query.eq('status', status.toLowerCase());
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('invoice_number', '%$searchQuery%');
    }

    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await query
        .order('created_at', ascending: false)
        .range(from, to);

    return (response as List)
        .map((json) => InvoiceModel.fromJson(json))
        .toList();
  }

  @override
  Future<InvoiceEntity> getInvoiceDetails(String id) async {
    final response = await _supabase
        .from('invoices')
        .select('*, customers(*), invoice_items(*)')
        .eq('id', id)
        .single();

    return InvoiceModel.fromJson(response);
  }

  @override
  Future<void> saveInvoice(InvoiceEntity invoice) async {
    final invoiceModel = InvoiceModel(
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      customerId: invoice.customerId,
      totalAmount: invoice.totalAmount,
      currency: invoice.currency,
      dueDate: invoice.dueDate,
      status: invoice.status,
      shippingCharge: invoice.shippingCharge,
      notes: invoice.notes,
      redirectUrl: invoice.redirectUrl,
      createdAt: invoice.createdAt,
    );

    final itemsData = invoice.items.map((item) {
      return InvoiceItemModel(
        id: item.id,
        description: item.description,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        discountPercent: item.discountPercent,
        vatPercent: item.vatPercent,
        total: item.total,
      ).toJson();
    }).toList();

    // Use RPC for atomic update/insert
    await _supabase.rpc(
      'create_invoice',
      params: {'invoice_data': invoiceModel.toJson(), 'items_data': itemsData},
    );
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _supabase.from('invoices').delete().eq('id', id);
  }

  @override
  Stream<List<InvoiceEntity>> watchInvoices() {
    return _supabase
        .from('invoices')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data.map((json) => InvoiceModel.fromJson(json)).toList(),
        );
  }
}
