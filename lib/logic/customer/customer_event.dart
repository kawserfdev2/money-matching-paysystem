import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/payment_repository.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  final bool isRefresh;
  const LoadCustomers({this.isRefresh = false});
}

class LoadNextPage extends CustomerEvent {}

class SearchCustomers extends CustomerEvent {
  final String query;
  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyCustomerFilters extends CustomerEvent {
  final String? city;
  final String? country;
  final PaymentDateRange? dateRange;

  const ApplyCustomerFilters({this.city, this.country, this.dateRange});

  @override
  List<Object?> get props => [city, country, dateRange];
}

class SaveCustomer extends CustomerEvent {
  final CustomerEntity customer;
  const SaveCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final String id;
  const DeleteCustomer(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCustomerInsights extends CustomerEvent {
  final String email;
  const LoadCustomerInsights(this.email);

  @override
  List<Object?> get props => [email];
}
