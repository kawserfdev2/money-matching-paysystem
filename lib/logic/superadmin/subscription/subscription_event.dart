import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptions extends SubscriptionEvent {
  final String filterStatus;
  const LoadSubscriptions({this.filterStatus = 'all'});

  @override
  List<Object?> get props => [filterStatus];
}

class FilterSubscriptions extends SubscriptionEvent {
  final String filterStatus;
  const FilterSubscriptions(this.filterStatus);

  @override
  List<Object?> get props => [filterStatus];
}

class ManualOverrideSubscription extends SubscriptionEvent {
  final String id;
  final String? newPlanId;
  final DateTime? newEndDate;
  final Function()? onSuccess;
  final Function(String)? onError;

  const ManualOverrideSubscription({
    required this.id,
    this.newPlanId,
    this.newEndDate,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [id, newPlanId, newEndDate];
}
