import '../entities/subscription_detail_entity.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionDetailEntity>> getSubscriptions({
    String filterStatus = 'all',
  });
  Future<void> updateSubscriptionPlan(String id, String newPlanId);
  Future<void> extendSubscriptionDate(String id, DateTime newEndDate);
}
