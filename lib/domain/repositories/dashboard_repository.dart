import '../entities/dashboard_stats.dart';
import '../entities/payment_entity.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();
  Future<List<PaymentEntity>> getLatestPayments();
  Stream<List<PaymentEntity>> watchPayments();
}
