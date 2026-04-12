import '../entities/customer_entity.dart';
import '../repositories/payment_repository.dart'; // For PaymentDateRange

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getCustomers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? city,
    String? country,
    PaymentDateRange? dateRange,
  });

  Future<CustomerEntity> getCustomerInsights(String email);

  Future<void> saveCustomer(CustomerEntity customer);

  Future<void> deleteCustomer(String id);

  Stream<List<CustomerEntity>> watchCustomers();
}
