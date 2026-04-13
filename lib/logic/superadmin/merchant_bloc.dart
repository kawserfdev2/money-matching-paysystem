import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/repositories/superadmin/superadmin_repository.dart';
import 'merchant_event.dart';
import 'merchant_state.dart';

class MerchantManagementBloc extends Bloc<MerchantEvent, MerchantState> {
  final SuperadminRepository _repository;
  static const int _pageSize = 20;

  MerchantManagementBloc(this._repository) : super(MerchantInitial()) {
    on<LoadMerchants>(_onLoadMerchants);
    on<LoadMoreMerchants>(_onLoadMore);
    on<FilterMerchants>(_onFilter);
    on<ToggleMerchantStatus>(_onToggleStatus);
    on<SearchMerchants>(
      _onSearch,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .asyncExpand(mapper),
    );
  }

  Future<void> _onLoadMerchants(
    LoadMerchants event,
    Emitter<MerchantState> emit,
  ) async {
    emit(MerchantLoading());
    try {
      debugPrint('🚀 [BLOC] Loading merchants (limit: $_pageSize)...');
      final merchants = await _repository.fetchMerchantSummaries(
        searchQuery: '',
        statusFilter: 'all',
        limit: _pageSize,
        offset: 0,
      );
      debugPrint('✅ [BLOC] Loaded ${merchants.length} merchants');
      emit(
        MerchantLoaded(
          merchants: merchants,
          hasReachedMax: merchants.length < _pageSize,
          query: '',
          statusFilter: 'all',
        ),
      );
    } catch (e) {
      debugPrint('❌ [BLOC] Error loading merchants: $e');
      emit(MerchantError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreMerchants event,
    Emitter<MerchantState> emit,
  ) async {
    final current = state;
    if (current is! MerchantLoaded || current.hasReachedMax) return;

    try {
      final moreItems = await _repository.fetchMerchantSummaries(
        searchQuery: current.query,
        statusFilter: current.statusFilter,
        limit: _pageSize,
        offset: current.merchants.length,
      );
      emit(
        current.copyWith(
          merchants: [...current.merchants, ...moreItems],
          hasReachedMax: moreItems.length < _pageSize,
        ),
      );
    } catch (_) {
      // silently fail pagination — keep current state
    }
  }

  Future<void> _onSearch(
    SearchMerchants event,
    Emitter<MerchantState> emit,
  ) async {
    final current = state;
    final currentFilter = current is MerchantLoaded
        ? current.statusFilter
        : 'all';

    emit(MerchantLoading());
    try {
      final merchants = await _repository.fetchMerchantSummaries(
        searchQuery: event.query,
        statusFilter: currentFilter,
        limit: _pageSize,
        offset: 0,
      );
      emit(
        MerchantLoaded(
          merchants: merchants,
          hasReachedMax: merchants.length < _pageSize,
          query: event.query,
          statusFilter: currentFilter,
        ),
      );
    } catch (e) {
      emit(MerchantError(e.toString()));
    }
  }

  Future<void> _onFilter(
    FilterMerchants event,
    Emitter<MerchantState> emit,
  ) async {
    final current = state;
    final currentQuery = current is MerchantLoaded ? current.query : '';

    emit(MerchantLoading());
    try {
      final merchants = await _repository.fetchMerchantSummaries(
        searchQuery: currentQuery,
        statusFilter: event.status,
        limit: _pageSize,
        offset: 0,
      );
      emit(
        MerchantLoaded(
          merchants: merchants,
          hasReachedMax: merchants.length < _pageSize,
          query: currentQuery,
          statusFilter: event.status,
        ),
      );
    } catch (e) {
      emit(MerchantError(e.toString()));
    }
  }

  Future<void> _onToggleStatus(
    ToggleMerchantStatus event,
    Emitter<MerchantState> emit,
  ) async {
    final current = state;
    if (current is! MerchantLoaded) return;

    final newStatus = event.currentStatus == 'active' ? 'suspended' : 'active';
    try {
      debugPrint(
        '🔄 [BLOC] Toggling status for merchant ${event.merchantId} to $newStatus',
      );
      // API call
      await _repository.updateMerchantStatus(event.merchantId, newStatus);

      // Update local state (Optimistic-style, after successful API)
      final updatedMerchants = current.merchants.map((m) {
        if (m.merchantId == event.merchantId) {
          return m.copyWith(status: newStatus);
        }
        return m;
      }).toList();

      debugPrint('✅ [BLOC] Status update successful');
      emit(current.copyWith(merchants: updatedMerchants));
      event.onSuccess();
    } catch (e) {
      debugPrint('❌ [BLOC] Error toggling status: $e');
      event.onError(e.toString());
    }
  }
}
