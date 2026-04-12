import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<PaymentEntity>> getPayments({
    int page = 0,
    int pageSize = 20,
    String? status,
    String? searchQuery,
    String? gateway,
    PaymentDateRange? dateRange,
  }) async {
    var query = _supabase.from('payments').select();

    // Filtering
    if (status != null && status != 'All') {
      query = query.eq('status', status.toLowerCase());
    }

    if (gateway != null && gateway != 'All') {
      query = query.eq('gateway', gateway);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Search in email OR transaction_id
      query = query.or(
        'customer_email.ilike.%$searchQuery%,transaction_id.ilike.%$searchQuery%',
      );
    }

    if (dateRange != null) {
      query = query.gte('created_at', dateRange.start.toIso8601String());
      query = query.lte('created_at', dateRange.end.toIso8601String());
    }

    // Pagination
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await query
        .order('created_at', ascending: false)
        .range(from, to);

    return (response as List)
        .map((json) => PaymentModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> createPayment(PaymentEntity payment) async {
    final model = PaymentModel(
      id: '',
      customerEmail: payment.customerEmail,
      gateway: payment.gateway,
      amount: payment.amount,
      netAmount: payment.netAmount,
      transactionId: payment.transactionId,
      createdAt: payment.createdAt,
      status: payment.status,
      currency: payment.currency,
      metadata: payment.metadata,
      ipAddress: payment.ipAddress,
      userAgent: payment.userAgent,
      gatewayResponse: payment.gatewayResponse,
    );
    await _supabase.from('payments').insert(model.toJson());
  }

  @override
  Stream<List<PaymentEntity>> watchPayments() {
    return _supabase
        .from('payments')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => data.map((json) => PaymentModel.fromJson(json)).toList(),
        );
  }
}
