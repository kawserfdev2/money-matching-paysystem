import 'package:equatable/equatable.dart';
import '../../../domain/repositories/system_log_repository.dart';

abstract class SystemLogsEvent extends Equatable {
  const SystemLogsEvent();
  @override
  List<Object?> get props => [];
}

class LoadLogs extends SystemLogsEvent {
  final bool isRefresh;
  const LoadLogs({this.isRefresh = false});
  @override
  List<Object?> get props => [isRefresh];
}

class FilterLogs extends SystemLogsEvent {
  final String? level;
  final String? source;
  final DateTimeRange? dateRange;

  const FilterLogs({this.level, this.source, this.dateRange});

  @override
  List<Object?> get props => [level, source, dateRange];
}

class MarkLogAsResolved extends SystemLogsEvent {
  final String logId;
  const MarkLogAsResolved(this.logId);
  @override
  List<Object?> get props => [logId];
}
