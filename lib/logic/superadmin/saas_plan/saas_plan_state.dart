import 'package:equatable/equatable.dart';
import '../../../domain/entities/saas_plan_entity.dart';

abstract class SaasPlanState extends Equatable {
  const SaasPlanState();

  @override
  List<Object?> get props => [];
}

class PlanInitial extends SaasPlanState {}

class PlanLoading extends SaasPlanState {}

class PlanLoaded extends SaasPlanState {
  final List<SaasPlanEntity> plans;

  const PlanLoaded({required this.plans});

  @override
  List<Object?> get props => [plans];
}

class PlanError extends SaasPlanState {
  final String message;

  const PlanError(this.message);

  @override
  List<Object?> get props => [message];
}

class PlanActionSuccess extends SaasPlanState {
  final String message;

  const PlanActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
