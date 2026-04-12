import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<ReportStatsEntity> getFinancialSummary() async {
    final response = await _supabase.rpc('get_financial_stats_summary');

    return ReportStatsEntity(
      todayRevenue: (response['today'] ?? 0).toDouble(),
      yesterdayRevenue: (response['yesterday'] ?? 0).toDouble(),
      thisWeekRevenue: (response['this_week'] ?? 0).toDouble(),
      lastWeekRevenue: (response['last_week'] ?? 0).toDouble(),
      thisMonthRevenue: (response['this_month'] ?? 0).toDouble(),
      lastMonthRevenue: (response['last_month'] ?? 0).toDouble(),
      thisYearRevenue: (response['this_year'] ?? 0).toDouble(),
      lastYearRevenue: (response['last_year'] ?? 0).toDouble(),
      successRate: (response['success_rate'] ?? 0).toDouble(),
    );
  }

  @override
  Future<List<ChartPointEntity>> getRevenueComparison() async {
    final List response = await _supabase.rpc('get_revenue_comparison_by_day');

    return response
        .map(
          (item) => ChartPointEntity(
            date: DateTime.parse(item['day']),
            currentRevenue: (item['current_revenue'] ?? 0).toDouble(),
            previousRevenue: (item['previous_revenue'] ?? 0).toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<List<List<dynamic>>> exportReportToCsv(
    DateTime start,
    DateTime end,
  ) async {
    // Fetch payments for the range
    final response = await _supabase
        .from('payments')
        .select('created_at, customer_email, gateway, amount, currency, status')
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    final List<List<dynamic>> rows = [];
    rows.add(['Date', 'Email', 'Gateway', 'Amount', 'Currency', 'Status']);

    for (var payment in response) {
      rows.add([
        payment['created_at'],
        payment['customer_email'],
        payment['gateway'],
        payment['amount'],
        payment['currency'],
        payment['status'],
      ]);
    }

    return rows;
  }
}
