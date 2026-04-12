import 'package:equatable/equatable.dart';
import '../../domain/entities/sms_log_entity.dart';

abstract class AutomationState extends Equatable {
  const AutomationState();
  @override
  List<Object?> get props => [];
}

class AutomationInitial extends AutomationState {}

class AutomationLoading extends AutomationState {}

class SmsLogsLoaded extends AutomationState {
  final List<SmsLogEntity> logs;
  const SmsLogsLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}

class AutomationError extends AutomationState {
  final String message;
  const AutomationError(this.message);
  @override
  List<Object?> get props => [message];
}
