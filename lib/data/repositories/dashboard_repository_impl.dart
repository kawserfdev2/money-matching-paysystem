import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/supabase_helper.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/payment_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardStats> getDashboardStats() async {
    int totalPayments = 0;
    int pendingPayments = 0;
    int unpaidInvoices = 0;
    int pendingSms = 0;
    List<double> weeklyVolume = List.filled(7, 0.0);

    try {
      final paymentsRes = await SupabaseHelper.queryFiltered(
        'payments',
        'id',
      ).eq('status', 'completed').count(CountOption.exact);
      totalPayments = paymentsRes.count;
    } catch (_) {}

    try {
      final pendingRes = await SupabaseHelper.queryFiltered(
        'payments',
        'id',
      ).eq('status', 'pending').count(CountOption.exact);
      pendingPayments = pendingRes.count;
    } catch (_) {}

    try {
      final unpaidRes = await SupabaseHelper.queryFiltered(
        'invoices',
        'id',
      ).eq('status', 'unpaid').count(CountOption.exact);
      unpaidInvoices = unpaidRes.count;
    } catch (_) {}

    try {
      final smsRes = await SupabaseHelper.queryFiltered(
        'sms_logs',
        'id',
      ).eq('status', 'pending').count(CountOption.exact);
      pendingSms = smsRes.count;
    } catch (_) {}

    try {
      final List<dynamic> recentData =
          await SupabaseHelper.queryFiltered('payments', 'amount, created_at')
              .eq('status', 'completed')
              .gte(
                'created_at',
                DateTime.now()
                    .subtract(const Duration(days: 7))
                    .toIso8601String(),
              );

      final now = DateTime.now();
      for (var item in recentData) {
        final date = DateTime.parse(item['created_at'] as String);
        final diff = now.difference(date).inDays;
        if (diff >= 0 && diff < 7) {
          weeklyVolume[6 - diff] += (item['amount'] as num).toDouble();
        }
      }
    } catch (_) {}

    return DashboardStats(
      totalPayments: totalPayments,
      pendingPayments: pendingPayments,
      unpaidInvoices: unpaidInvoices,
      pendingSms: pendingSms,
      weeklyVolume: weeklyVolume,
    );
  }

  @override
  Future<List<PaymentEntity>> getLatestPayments() async {
    try {
      final response = await SupabaseHelper.queryFiltered(
        'payments',
      ).order('created_at', ascending: false).limit(10);

      return (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Stream<List<PaymentEntity>> watchPayments() {
    try {
      return SupabaseHelper.streamFiltered('payments', ['id'])
          .order('created_at', ascending: false)
          .limit(10)
          .map(
            (data) => data.map((json) => PaymentModel.fromJson(json)).toList(),
          );
    } catch (_) {
      return Stream.value([]);
    }
  }
}
