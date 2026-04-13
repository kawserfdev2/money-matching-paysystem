import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/repositories/system_log_repository.dart';
import 'system_logs_event.dart';
import 'system_logs_state.dart';

class SystemLogsBloc extends Bloc<SystemLogsEvent, SystemLogsState> {
  final SystemLogRepository _repository;
  RealtimeChannel? _realtimeChannel;

  SystemLogsBloc(this._repository) : super(LogsInitial()) {
    on<LoadLogs>(_onLoadLogs);
    on<FilterLogs>(_onFilterLogs);
    on<MarkLogAsResolved>(_onMarkAsResolved);

    _initRealtime();
  }

  void _initRealtime() {
    debugPrint('🔌 [SystemLogsBloc] Initializing Realtime for system_logs');
    _realtimeChannel = Supabase.instance.client
        .channel('public:system_logs')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'system_logs',
          callback: (payload) {
            debugPrint('🚨 [REALTIME] New log entry detected!');
            final level = payload.newRecord['level'] as String;
            // Auto reload on errors or criticals
            if (level == 'error' || level == 'critical') {
              add(const LoadLogs());
            }
          },
        );

    _realtimeChannel!.subscribe();
  }

  Future<void> _onLoadLogs(
    LoadLogs event,
    Emitter<SystemLogsState> emit,
  ) async {
    if (event.isRefresh || state is! LogsLoaded) {
      emit(LogsLoading());
    }

    try {
      final logs = await _repository.getLogs();
      emit(LogsLoaded(logs: logs));
    } catch (e) {
      emit(LogsError(e.toString()));
    }
  }

  Future<void> _onFilterLogs(
    FilterLogs event,
    Emitter<SystemLogsState> emit,
  ) async {
    emit(LogsLoading());
    try {
      final logs = await _repository.getLogs(
        level: event.level,
        source: event.source,
        dateRange: event.dateRange,
      );
      emit(
        LogsLoaded(
          logs: logs,
          levelFilter: event.level,
          sourceFilter: event.source,
        ),
      );
    } catch (e) {
      emit(LogsError(e.toString()));
    }
  }

  Future<void> _onMarkAsResolved(
    MarkLogAsResolved event,
    Emitter<SystemLogsState> emit,
  ) async {
    try {
      await _repository.markAsResolved(event.logId);
      // Reload current view
      if (state is LogsLoaded) {
        final current = state as LogsLoaded;
        // Just re-fetch to ensure all filters are respected
        add(
          FilterLogs(level: current.levelFilter, source: current.sourceFilter),
        );
      }
    } catch (e) {
      // Optional: Handle error
    }
  }

  @override
  Future<void> close() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    return super.close();
  }
}
