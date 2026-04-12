import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> getPayments({
    int page = 0,
    int pageSize = 20,
    String? status,
    String? searchQuery,
    String? gateway,
    PaymentDateRange? dateRange,
  });

  Future<void> createPayment(PaymentEntity payment);

  Stream<List<PaymentEntity>> watchPayments();
}

class PaymentDateRange {
  final DateTime start;
  final DateTime end;

  PaymentDateRange({required this.start, required this.end});
}
