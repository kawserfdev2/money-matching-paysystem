import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;
  static const int _pageSize = 20;

  PaymentBloc(this._repository) : super(PaymentInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<FilterByStatus>(_onFilterByStatus);
    on<ApplyAdvancedFilters>(_onApplyAdvancedFilters);
    on<SearchPayments>(
      _onSearchPayments,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .flatMap(mapper),
    );
    on<LoadNextPage>(_onLoadNextPage);
  }

  Future<void> _onLoadPayments(
    LoadPayments event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;

    String status = 'All';
    String? gateway;
    String? query;
    PaymentDateRange? range;

    if (currentState is PaymentLoaded && !event.isRefresh) {
      status = currentState.currentStatus;
      gateway = currentState.currentGateway;
      query = currentState.searchQuery;
      range = currentState.dateRange;
    }

    emit(const PaymentLoading(isFirstLoad: true));

    try {
      final payments = await _repository.getPayments(
        page: 0,
        pageSize: _pageSize,
        status: status,
        gateway: gateway,
        searchQuery: query,
        dateRange: range,
      );

      emit(
        PaymentLoaded(
          payments: payments,
          hasReachedMax: payments.length < _pageSize,
          currentStatus: status,
          currentGateway: gateway,
          searchQuery: query,
          dateRange: range,
          currentPage: 0,
        ),
      );
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentLoaded) {
      if (currentState.currentStatus == event.status) return;
      add(const LoadPayments(isRefresh: true));
    } else {
      emit(PaymentLoaded(payments: const [], currentStatus: event.status));
      add(const LoadPayments(isRefresh: true));
    }
  }

  Future<void> _onApplyAdvancedFilters(
    ApplyAdvancedFilters event,
    Emitter<PaymentState> emit,
  ) async {
    add(const LoadPayments(isRefresh: true));
  }

  Future<void> _onSearchPayments(
    SearchPayments event,
    Emitter<PaymentState> emit,
  ) async {
    add(const LoadPayments(isRefresh: true));
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<PaymentState> emit,
  ) async {
    final currentState = state;
    if (currentState is PaymentLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final payments = await _repository.getPayments(
          page: nextPage,
          pageSize: _pageSize,
          status: currentState.currentStatus,
          gateway: currentState.currentGateway,
          searchQuery: currentState.searchQuery,
          dateRange: currentState.dateRange,
        );

        if (payments.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              payments: List.of(currentState.payments)..addAll(payments),
              currentPage: nextPage,
              hasReachedMax: payments.length < _pageSize,
            ),
          );
        }
      } catch (e) {
        emit(PaymentError(e.toString()));
      }
    }
  }
}
