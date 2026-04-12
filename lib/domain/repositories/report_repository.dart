import '../entities/report_entities.dart';

abstract class ReportRepository {
  Future<ReportStatsEntity> getFinancialSummary();

  Future<List<ChartPointEntity>> getRevenueComparison();

  Future<List<List<dynamic>>> exportReportToCsv(DateTime start, DateTime end);
}
