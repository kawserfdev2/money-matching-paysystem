import 'package:equatable/equatable.dart';

abstract class SaasPlanEvent extends Equatable {
  const SaasPlanEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlans extends SaasPlanEvent {
  final bool includeInactive;
  final bool isRefresh;

  const LoadPlans({this.includeInactive = true, this.isRefresh = false});

  @override
  List<Object?> get props => [includeInactive, isRefresh];
}

class CreatePlan extends SaasPlanEvent {
  final String name;
  final double price;
  final int monthlyPaymentLimit;
  final List<String> features;
  final Function()? onSuccess;
  final Function(String)? onError;

  const CreatePlan({
    required this.name,
    required this.price,
    required this.monthlyPaymentLimit,
    required this.features,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [name, price, monthlyPaymentLimit, features];
}

class UpdatePlan extends SaasPlanEvent {
  final String id;
  final String name;
  final double price;
  final int monthlyPaymentLimit;
  final List<String> features;
  final bool isActive;
  final Function()? onSuccess;
  final Function(String)? onError;

  const UpdatePlan({
    required this.id,
    required this.name,
    required this.price,
    required this.monthlyPaymentLimit,
    required this.features,
    required this.isActive,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    monthlyPaymentLimit,
    features,
    isActive,
  ];
}

class TogglePlanStatus extends SaasPlanEvent {
  final String id;
  final bool isActive;
  final Function()? onSuccess;
  final Function(String)? onError;

  const TogglePlanStatus({
    required this.id,
    required this.isActive,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [id, isActive];
}
