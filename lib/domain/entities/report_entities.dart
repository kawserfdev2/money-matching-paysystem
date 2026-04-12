import 'package:equatable/equatable.dart';

class ReportStatsEntity extends Equatable {
  final double todayRevenue;
  final double yesterdayRevenue;
  final double thisWeekRevenue;
  final double lastWeekRevenue;
  final double thisMonthRevenue;
  final double lastMonthRevenue;
  final double thisYearRevenue;
  final double lastYearRevenue;
  final double successRate;

  const ReportStatsEntity({
    required this.todayRevenue,
    required this.yesterdayRevenue,
    required this.thisWeekRevenue,
    required this.lastWeekRevenue,
    required this.thisMonthRevenue,
    required this.lastMonthRevenue,
    required this.thisYearRevenue,
    required this.lastYearRevenue,
    required this.successRate,
  });

  double get todayChange => _calcChange(todayRevenue, yesterdayRevenue);
  double get weekChange => _calcChange(thisWeekRevenue, lastWeekRevenue);
  double get monthChange => _calcChange(thisMonthRevenue, lastMonthRevenue);
  double get yearChange => _calcChange(thisYearRevenue, lastYearRevenue);

  double _calcChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  @override
  List<Object?> get props => [
    todayRevenue,
    yesterdayRevenue,
    thisWeekRevenue,
    lastWeekRevenue,
    thisMonthRevenue,
    lastMonthRevenue,
    thisYearRevenue,
    lastYearRevenue,
    successRate,
  ];
}

class ChartPointEntity extends Equatable {
  final DateTime date;
  final double currentRevenue;
  final double previousRevenue;

  const ChartPointEntity({
    required this.date,
    required this.currentRevenue,
    required this.previousRevenue,
  });

  @override
  List<Object?> get props => [date, currentRevenue, previousRevenue];
}
