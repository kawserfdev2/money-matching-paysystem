import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardData extends DashboardEvent {}

class UpdateRealtimeStats extends DashboardEvent {
  final List<PaymentEntity> latestPayments;

  const UpdateRealtimeStats(this.latestPayments);

  @override
  List<Object?> get props => [latestPayments];
}
