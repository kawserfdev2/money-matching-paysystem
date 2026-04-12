import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {
  final bool isFirstLoad;
  const PaymentLoading({this.isFirstLoad = true});

  @override
  List<Object?> get props => [isFirstLoad];
}

class PaymentLoaded extends PaymentState {
  final List<PaymentEntity> payments;
  final bool hasReachedMax;
  final String currentStatus;
  final String? currentGateway;
  final String? searchQuery;
  final PaymentDateRange? dateRange;
  final int currentPage;

  const PaymentLoaded({
    required this.payments,
    this.hasReachedMax = false,
    this.currentStatus = 'All',
    this.currentGateway,
    this.searchQuery,
    this.dateRange,
    this.currentPage = 0,
  });

  PaymentLoaded copyWith({
    List<PaymentEntity>? payments,
    bool? hasReachedMax,
    String? currentStatus,
    String? currentGateway,
    String? searchQuery,
    PaymentDateRange? dateRange,
    int? currentPage,
  }) {
    return PaymentLoaded(
      payments: payments ?? this.payments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentStatus: currentStatus ?? this.currentStatus,
      currentGateway: currentGateway ?? this.currentGateway,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: dateRange ?? this.dateRange,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    payments,
    hasReachedMax,
    currentStatus,
    currentGateway,
    searchQuery,
    dateRange,
    currentPage,
  ];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
