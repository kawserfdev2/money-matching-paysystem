import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'saas_plan_event.dart';
import 'saas_plan_state.dart';
import '../../../domain/entities/saas_plan_entity.dart';
import '../../../domain/repositories/saas_plan_repository.dart';

class SaasPlanBloc extends Bloc<SaasPlanEvent, SaasPlanState> {
  final SaasPlanRepository _repository;

  SaasPlanBloc(this._repository) : super(PlanInitial()) {
    on<LoadPlans>(_onLoadPlans);
    on<CreatePlan>(_onCreatePlan);
    on<UpdatePlan>(_onUpdatePlan);
    on<TogglePlanStatus>(_onTogglePlanStatus);
  }

  Future<void> _onLoadPlans(
    LoadPlans event,
    Emitter<SaasPlanState> emit,
  ) async {
    if (!event.isRefresh) emit(PlanLoading());
    try {
      debugPrint(
        '🚀 [BLOC] Loading SaaS plans (refresh: ${event.isRefresh})...',
      );
      final plans = await _repository.getPlans(
        includeInactive: event.includeInactive,
      );
      debugPrint('✅ [BLOC] Loaded ${plans.length} plans');
      emit(PlanLoaded(plans: plans));
    } catch (e) {
      debugPrint('❌ [BLOC] Error loading plans: $e');
      emit(PlanError(e.toString()));
    }
  }

  Future<void> _onCreatePlan(
    CreatePlan event,
    Emitter<SaasPlanState> emit,
  ) async {
    try {
      debugPrint('➕ [BLOC] Creating new plan: ${event.name}');
      final newPlan = SaasPlanEntity(
        id: '',
        name: event.name,
        price: event.price,
        monthlyPaymentLimit: event.monthlyPaymentLimit,
        features: event.features,
        isActive: true,
      );
      await _repository.createPlan(newPlan);
      debugPrint('✅ [BLOC] Plan created successfully');
      event.onSuccess?.call();
      add(const LoadPlans(isRefresh: true));
    } catch (e) {
      debugPrint('❌ [BLOC] Error creating plan: $e');
      final errorPrefix = e.toString().contains('Exception:')
          ? ''
          : 'Failed to create plan: ';
      final msg = '$errorPrefix${e.toString().replaceAll('Exception: ', '')}';
      event.onError?.call(msg);
      // Wait, we don't want to break the PlanLoaded state, so we don't emit error
    }
  }

  Future<void> _onUpdatePlan(
    UpdatePlan event,
    Emitter<SaasPlanState> emit,
  ) async {
    try {
      final updated = SaasPlanEntity(
        id: event.id,
        name: event.name,
        price: event.price,
        monthlyPaymentLimit: event.monthlyPaymentLimit,
        features: event.features,
        isActive: event.isActive,
      );
      await _repository.updatePlan(updated);
      event.onSuccess?.call();
      add(const LoadPlans(isRefresh: true));
    } catch (e) {
      final errorPrefix = e.toString().contains('Exception:')
          ? ''
          : 'Failed to update plan: ';
      final msg = '$errorPrefix${e.toString().replaceAll('Exception: ', '')}';
      event.onError?.call(msg);
    }
  }

  Future<void> _onTogglePlanStatus(
    TogglePlanStatus event,
    Emitter<SaasPlanState> emit,
  ) async {
    try {
      await _repository.togglePlanStatus(event.id, event.isActive);
      event.onSuccess?.call();
      add(const LoadPlans(isRefresh: true));
    } catch (e) {
      final errorPrefix = e.toString().contains('Exception:')
          ? ''
          : 'Failed to toggle status: ';
      final msg = '$errorPrefix${e.toString().replaceAll('Exception: ', '')}';
      event.onError?.call(msg);
    }
  }
}
