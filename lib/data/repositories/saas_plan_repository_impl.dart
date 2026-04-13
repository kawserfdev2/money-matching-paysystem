import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/saas_plan_entity.dart';
import '../../domain/repositories/saas_plan_repository.dart';
import '../models/superadmin/saas_plan_model.dart';

class SaasPlanRepositoryImpl implements SaasPlanRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<SaasPlanEntity>> getPlans({bool includeInactive = false}) async {
    var query = _supabase.from('saas_plans').select();

    if (!includeInactive) {
      query = query.eq('is_active', true);
    }

    final List<dynamic> response = await query.order('price', ascending: true);
    return response.map((json) => SaasPlanModel.fromJson(json)).toList();
  }

  @override
  Future<SaasPlanEntity> createPlan(SaasPlanEntity plan) async {
    final model = SaasPlanModel.fromEntity(plan);
    final response = await _supabase
        .from('saas_plans')
        .insert(model.toJson())
        .select()
        .single();
    return SaasPlanModel.fromJson(response);
  }

  @override
  Future<SaasPlanEntity> updatePlan(SaasPlanEntity plan) async {
    final model = SaasPlanModel.fromEntity(plan);
    final response = await _supabase
        .from('saas_plans')
        .update(model.toJson())
        .eq('id', plan.id)
        .select()
        .single();
    return SaasPlanModel.fromJson(response);
  }

  @override
  Future<void> togglePlanStatus(String id, bool isActive) async {
    await _supabase
        .from('saas_plans')
        .update({'is_active': isActive})
        .eq('id', id);
  }
}
