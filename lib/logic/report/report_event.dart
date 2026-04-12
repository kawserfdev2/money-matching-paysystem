import 'package:equatable/equatable.dart';
import '../../domain/entities/report_entities.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class FetchReportStats extends ReportEvent {}

class FilterReportByDate extends ReportEvent {
  final DateTime start;
  final DateTime end;
  const FilterReportByDate(this.start, this.end);
  @override
  List<Object?> get props => [start, end];
}

class ExportReport extends ReportEvent {
  final DateTime start;
  final DateTime end;
  const ExportReport(this.start, this.end);
  @override
  List<Object?> get props => [start, end];
}
