import '../entities/system_log_entity.dart';

abstract class SystemLogRepository {
  Future<List<SystemLogEntity>> getLogs({
    String? level,
    String? source,
    DateTimeRange? dateRange,
  });
  Future<void> markAsResolved(String logId);
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
}
