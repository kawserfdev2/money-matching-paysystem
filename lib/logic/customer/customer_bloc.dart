import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _customerRepository;
  static const int _pageSize = 20;

  CustomerBloc(this._customerRepository) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<LoadNextPage>(_onLoadNextPage);
    on<SearchCustomers>(
      _onSearchCustomers,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .flatMap(mapper),
    );
    on<ApplyCustomerFilters>(_onApplyFilters);
    on<SaveCustomer>(_onSaveCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<LoadCustomerInsights>(_onLoadInsights);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading(isFirstLoad: true));
    try {
      final customers = await _customerRepository.getCustomers(
        page: 0,
        pageSize: _pageSize,
      );

      emit(
        CustomerLoaded(
          customers: customers,
          hasReachedMax: customers.length < _pageSize,
          currentPage: 0,
        ),
      );
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<CustomerState> emit,
  ) async {
    final currentState = state;
    if (currentState is CustomerLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final nextCustomers = await _customerRepository.getCustomers(
          page: nextPage,
          pageSize: _pageSize,
          searchQuery: currentState.searchQuery,
          city: currentState.city,
          country: currentState.country,
          dateRange: currentState.dateRange,
        );

        emit(
          currentState.copyWith(
            customers: List.of(currentState.customers)..addAll(nextCustomers),
            hasReachedMax: nextCustomers.length < _pageSize,
            currentPage: nextPage,
          ),
        );
      } catch (e) {
        emit(CustomerError(e.toString()));
      }
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    await _fetchWithFilters(emit, searchQuery: event.query);
  }

  Future<void> _onApplyFilters(
    ApplyCustomerFilters event,
    Emitter<CustomerState> emit,
  ) async {
    await _fetchWithFilters(
      emit,
      city: event.city,
      country: event.country,
      dateRange: event.dateRange,
    );
  }

  Future<void> _fetchWithFilters(
    Emitter<CustomerState> emit, {
    String? searchQuery,
    String? city,
    String? country,
    PaymentDateRange? dateRange,
  }) async {
    final currentState = state;
    String? query = searchQuery;
    String? cty = city;
    String? cntry = country;
    PaymentDateRange? range = dateRange;

    if (currentState is CustomerLoaded) {
      query ??= currentState.searchQuery;
      cty ??= currentState.city;
      cntry ??= currentState.country;
      range ??= currentState.dateRange;
    }

    emit(const CustomerLoading(isFirstLoad: true));
    try {
      final customers = await _customerRepository.getCustomers(
        page: 0,
        pageSize: _pageSize,
        searchQuery: query,
        city: cty,
        country: cntry,
        dateRange: range,
      );

      emit(
        CustomerLoaded(
          customers: customers,
          hasReachedMax: customers.length < _pageSize,
          currentPage: 0,
          searchQuery: query,
          city: cty,
          country: cntry,
          dateRange: range,
        ),
      );
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSaveCustomer(
    SaveCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _customerRepository.saveCustomer(event.customer);
      emit(const CustomerActionSuccess("Customer saved successfully"));
      add(const LoadCustomers(isRefresh: true));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _customerRepository.deleteCustomer(event.id);
      emit(const CustomerActionSuccess("Customer deleted successfully"));
      add(const LoadCustomers(isRefresh: true));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadInsights(
    LoadCustomerInsights event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading(isFirstLoad: false));
    try {
      final customer = await _customerRepository.getCustomerInsights(
        event.email,
      );
      emit(CustomerInsightsLoaded(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
