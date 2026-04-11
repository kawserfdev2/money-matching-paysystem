import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/payment_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<PaymentEntity> latestPayments;

  const DashboardLoaded({required this.stats, required this.latestPayments});

  @override
  List<Object?> get props => [stats, latestPayments];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
