import 'package:equatable/equatable.dart';
import '../../../domain/entities/subscription_detail_entity.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionDetailEntity> subscriptions;
  final String currentFilter;

  const SubscriptionLoaded({
    required this.subscriptions,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [subscriptions, currentFilter];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
