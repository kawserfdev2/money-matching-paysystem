import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amarpay/domain/repositories/automation_repository.dart';
import 'package:amarpay/domain/repositories/activity_repository.dart';
import 'package:amarpay/domain/entities/activity_entity.dart';
import 'package:amarpay/domain/entities/sms_log_entity.dart';
import 'automation_event.dart';
import 'automation_state.dart';

class AutomationBloc extends Bloc<AutomationEvent, AutomationState> {
  final AutomationRepository _automationRepository;
  final ActivityRepository _activityRepository;

  AutomationBloc(this._automationRepository, this._activityRepository)
    : super(AutomationInitial()) {
    on<WatchSmsLogs>(_onWatchLogs);
    on<SyncSmsManually>(_onSyncSms);
  }

  Future<void> _onWatchLogs(
    WatchSmsLogs event,
    Emitter<AutomationState> emit,
  ) async {
    await emit.forEach(
      _automationRepository.watchSmsLogs(),
      onData: (logs) => SmsLogsLoaded(logs),
      onError: (e, stack) => AutomationError(e.toString()),
    );
  }

  Future<void> _onSyncSms(
    SyncSmsManually event,
    Emitter<AutomationState> emit,
  ) async {
    try {
      await _automationRepository.syncSmsManually(event.body, event.sender);

      // Log Activity
      await _activityRepository.logAction(
        action: "Manual SMS Sync",
        resource: event.sender,
        metadata: {
          'body_snippet': event.body.substring(0, min(20, event.body.length)),
        },
      );
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }
}
