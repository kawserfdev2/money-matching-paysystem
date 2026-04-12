import '../entities/invoice_entity.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceEntity>> getInvoices({
    required int page,
    required int pageSize,
    String? status,
    String? searchQuery,
  });

  Future<InvoiceEntity> getInvoiceDetails(String id);

  Future<void> saveInvoice(InvoiceEntity invoice);

  Future<void> deleteInvoice(String id);

  Stream<List<InvoiceEntity>> watchInvoices();
}
