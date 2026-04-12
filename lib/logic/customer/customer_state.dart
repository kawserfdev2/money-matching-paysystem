import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/payment_repository.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {
  final bool isFirstLoad;
  const CustomerLoading({this.isFirstLoad = true});

  @override
  List<Object?> get props => [isFirstLoad];
}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  final bool hasReachedMax;
  final String? city;
  final String? country;
  final String? searchQuery;
  final PaymentDateRange? dateRange;
  final int currentPage;

  const CustomerLoaded({
    required this.customers,
    this.hasReachedMax = false,
    this.city,
    this.country,
    this.searchQuery,
    this.dateRange,
    this.currentPage = 0,
  });

  CustomerLoaded copyWith({
    List<CustomerEntity>? customers,
    bool? hasReachedMax,
    String? city,
    String? country,
    String? searchQuery,
    PaymentDateRange? dateRange,
    int? currentPage,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      city: city ?? this.city,
      country: country ?? this.country,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: dateRange ?? this.dateRange,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    customers,
    hasReachedMax,
    city,
    country,
    searchQuery,
    dateRange,
    currentPage,
  ];
}

class CustomerInsightsLoaded extends CustomerState {
  final CustomerEntity customer;
  const CustomerInsightsLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerActionSuccess extends CustomerState {
  final String message;
  const CustomerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
