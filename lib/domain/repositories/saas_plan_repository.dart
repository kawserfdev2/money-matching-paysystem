import '../entities/saas_plan_entity.dart';

abstract class SaasPlanRepository {
  Future<List<SaasPlanEntity>> getPlans({bool includeInactive = false});
  Future<SaasPlanEntity> createPlan(SaasPlanEntity plan);
  Future<SaasPlanEntity> updatePlan(SaasPlanEntity plan);
  Future<void> togglePlanStatus(String id, bool isActive);
}
