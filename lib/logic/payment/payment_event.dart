import 'package:equatable/equatable.dart';
import '../../domain/repositories/payment_repository.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentEvent {
  final bool isRefresh;

  const LoadPayments({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterByStatus extends PaymentEvent {
  final String status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class ApplyAdvancedFilters extends PaymentEvent {
  final String? gateway;
  final PaymentDateRange? dateRange;

  const ApplyAdvancedFilters({this.gateway, this.dateRange});

  @override
  List<Object?> get props => [gateway, dateRange];
}

class SearchPayments extends PaymentEvent {
  final String query;

  const SearchPayments(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadNextPage extends PaymentEvent {}
