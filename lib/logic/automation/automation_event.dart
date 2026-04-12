import 'package:equatable/equatable.dart';
import '../../domain/entities/sms_log_entity.dart';

abstract class AutomationEvent extends Equatable {
  const AutomationEvent();
  @override
  List<Object?> get props => [];
}

class WatchSmsLogs extends AutomationEvent {}

class SyncSmsManually extends AutomationEvent {
  final String body;
  final String sender;
  const SyncSmsManually(this.body, this.sender);
  @override
  List<Object?> get props => [body, sender];
}
