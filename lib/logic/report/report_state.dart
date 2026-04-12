import 'package:equatable/equatable.dart';
import '../../domain/entities/report_entities.dart';

abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final ReportStatsEntity stats;
  final List<ChartPointEntity> chartData;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportLoaded({
    required this.stats,
    required this.chartData,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [stats, chartData, startDate, endDate];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
  @override
  List<Object?> get props => [message];
}
