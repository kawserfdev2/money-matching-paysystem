import '../entities/payment_link_entity.dart';

abstract class PaymentLinkRepository {
  Future<List<PaymentLinkEntity>> getPaymentLinks();

  Future<PaymentLinkEntity?> getPaymentLinkBySlug(String slug);

  Future<void> createPaymentLink(PaymentLinkEntity link);

  Future<void> updatePaymentLinkStatus(String id, bool isActive);

  Future<void> deletePaymentLink(String id);
}
