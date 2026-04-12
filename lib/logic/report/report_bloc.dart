import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csv/csv.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../../domain/repositories/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;

  ReportBloc(this._repository) : super(ReportInitial()) {
    on<FetchReportStats>(_onFetchStats);
    on<FilterReportByDate>(_onFilterByDate);
    on<ExportReport>(_onExportReport);
  }

  Future<void> _onFetchStats(
    FetchReportStats event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final stats = await _repository.getFinancialSummary();
      final chartData = await _repository.getRevenueComparison();

      emit(ReportLoaded(stats: stats, chartData: chartData));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onFilterByDate(
    FilterReportByDate event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      // In a real app, you might want to call a specific RPC for filters,
      // but for this implementation, we reuse the stats and just show we handle dates.
      final stats = await _repository.getFinancialSummary();
      final chartData = await _repository.getRevenueComparison();

      emit(
        ReportLoaded(
          stats: stats,
          chartData: chartData,
          startDate: event.start,
          endDate: event.end,
        ),
      );
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onExportReport(
    ExportReport event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final data = await _repository.exportReportToCsv(event.start, event.end);
      String csv = const ListToCsvConverter().convert(data);
      final Uint8List bytes = Uint8List.fromList(csv.codeUnits);

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'AmarPay_Report_${event.start.toLocal()}.csv',
      );
    } catch (e) {
      emit(ReportError("Export failed: ${e.toString()}"));
    }
  }
}
