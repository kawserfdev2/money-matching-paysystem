import 'package:equatable/equatable.dart';
import '../../domain/entities/activity_entity.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => [];
}

class WatchActivityLogs extends ActivityEvent {}
