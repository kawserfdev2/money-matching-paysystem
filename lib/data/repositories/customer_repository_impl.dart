import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<CustomerEntity>> getCustomers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? city,
    String? country,
    PaymentDateRange? dateRange,
  }) async {
    var query = _supabase.from('customers').select();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'first_name.ilike.%$searchQuery%,last_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%,phone.ilike.%$searchQuery%',
      );
    }

    if (city != null && city != 'All') {
      query = query.eq('city', city);
    }

    if (country != null && country != 'All') {
      query = query.eq('country', country);
    }

    if (dateRange != null) {
      query = query
          .gte('created_at', dateRange.start.toIso8601String())
          .lte('created_at', dateRange.end.toIso8601String());
    }

    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await query
        .order('created_at', ascending: false)
        .range(from, to);

    return (response as List)
        .map((json) => CustomerModel.fromJson(json))
        .toList();
  }

  @override
  Future<CustomerEntity> getCustomerInsights(String email) async {
    // Supabase relational query to get customer + their payments for stats
    final response = await _supabase
        .from('customers')
        .select('*, payments(amount, status)')
        .eq('email', email)
        .single();

    return CustomerModel.fromJson(response);
  }

  @override
  Future<void> saveCustomer(CustomerEntity customer) async {
    final model = CustomerModel(
      id: customer.id,
      firstName: customer.firstName,
      lastName: customer.lastName,
      email: customer.email,
      phone: customer.phone,
      company: customer.company,
      address: customer.address,
      city: customer.city,
      state: customer.state,
      postcode: customer.postcode,
      country: customer.country,
      createdFrom: customer.createdFrom,
      createdAt: customer.createdAt,
    );

    if (customer.id.isEmpty || customer.id == 'new') {
      await _supabase.from('customers').insert(model.toJson());
    } else {
      await _supabase
          .from('customers')
          .update(model.toJson())
          .eq('id', customer.id);
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _supabase.from('customers').delete().eq('id', id);
  }

  @override
  Stream<List<CustomerEntity>> watchCustomers() {
    return _supabase
        .from('customers')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data.map((json) => CustomerModel.fromJson(json)).toList(),
        );
  }
}
