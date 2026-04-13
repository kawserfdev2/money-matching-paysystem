import 'package:equatable/equatable.dart';
import '../../../domain/entities/system_log_entity.dart';

abstract class SystemLogsState extends Equatable {
  const SystemLogsState();
  @override
  List<Object?> get props => [];
}

class LogsInitial extends SystemLogsState {}

class LogsLoading extends SystemLogsState {}

class LogsLoaded extends SystemLogsState {
  final List<SystemLogEntity> logs;
  final String? levelFilter;
  final String? sourceFilter;

  const LogsLoaded({required this.logs, this.levelFilter, this.sourceFilter});

  @override
  List<Object?> get props => [logs, levelFilter, sourceFilter];
}

class LogsError extends SystemLogsState {
  final String message;
  const LogsError(this.message);
  @override
  List<Object?> get props => [message];
}
