import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';
import '../../../domain/repositories/subscription_repository.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionBloc(this._repository) : super(SubscriptionInitial()) {
    on<LoadSubscriptions>(_onLoadSubscriptions);
    on<FilterSubscriptions>(_onFilterSubscriptions);
    on<ManualOverrideSubscription>(_onManualOverride);
  }

  Future<void> _onLoadSubscriptions(
    LoadSubscriptions event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      debugPrint(
        '🚀 [BLOC] Loading subscriptions (filter: ${event.filterStatus})...',
      );
      final data = await _repository.getSubscriptions(
        filterStatus: event.filterStatus,
      );
      debugPrint('✅ [BLOC] Loaded ${data.length} subscriptions');
      emit(
        SubscriptionLoaded(
          subscriptions: data,
          currentFilter: event.filterStatus,
        ),
      );
    } catch (e) {
      debugPrint('❌ [BLOC] Error loading subscriptions: $e');
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onFilterSubscriptions(
    FilterSubscriptions event,
    Emitter<SubscriptionState> emit,
  ) async {
    add(LoadSubscriptions(filterStatus: event.filterStatus));
  }

  Future<void> _onManualOverride(
    ManualOverrideSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      debugPrint('🛠️ [BLOC] Manual override subscription ${event.id}');
      if (event.newPlanId != null) {
        debugPrint('   - Setting new plan: ${event.newPlanId}');
        await _repository.updateSubscriptionPlan(event.id, event.newPlanId!);
      }
      if (event.newEndDate != null) {
        debugPrint('   - Extending end date to: ${event.newEndDate}');
        await _repository.extendSubscriptionDate(event.id, event.newEndDate!);
      }

      debugPrint('✅ [BLOC] Subscription override successful');
      event.onSuccess?.call();

      // Reload current filter
      final currentState = state;
      String filter = 'all';
      if (currentState is SubscriptionLoaded) {
        filter = currentState.currentFilter;
      }
      add(LoadSubscriptions(filterStatus: filter));
    } catch (e) {
      debugPrint('❌ [BLOC] Error in manual override: $e');
      event.onError?.call(e.toString());
    }
  }
}
