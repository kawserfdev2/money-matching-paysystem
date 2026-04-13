import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/subscription_detail_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../models/superadmin/subscription_detail_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<SubscriptionDetailEntity>> getSubscriptions({
    String filterStatus = 'all',
  }) async {
    var query = _supabase.from('get_subscription_details').select();

    if (filterStatus != 'all') {
      if (filterStatus == 'expiring_soon') {
        final nextWeek = DateTime.now()
            .add(const Duration(days: 7))
            .toUtc()
            .toIso8601String();
        final now = DateTime.now().toUtc().toIso8601String();
        query = query
            .lte('end_date', nextWeek)
            .gte('end_date', now)
            .eq('status', 'active');
      } else {
        query = query.eq('status', filterStatus);
      }
    }

    final response = await query.order('end_date', ascending: true);
    return (response as List)
        .map<SubscriptionDetailEntity>(
          (json) => SubscriptionDetailModel.fromJson(json),
        )
        .toList();
  }

  @override
  Future<void> updateSubscriptionPlan(String id, String newPlanId) async {
    await _supabase
        .from('merchant_subscriptions')
        .update({'plan_id': newPlanId})
        .eq('id', id);
  }

  @override
  Future<void> extendSubscriptionDate(String id, DateTime newEndDate) async {
    await _supabase
        .from('merchant_subscriptions')
        .update({'end_date': newEndDate.toUtc().toIso8601String()})
        .eq('id', id);
  }
}
