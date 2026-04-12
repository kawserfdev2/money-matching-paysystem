import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amarpay/domain/repositories/activity_repository.dart';
import 'package:amarpay/domain/entities/activity_entity.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _repository;

  ActivityBloc(this._repository) : super(ActivityInitial()) {
    on<WatchActivityLogs>((event, emit) async {
      await emit.forEach(
        _repository.watchActivityLogs(),
        onData: (activities) => ActivitiesLoaded(activities),
        onError: (e, stack) => ActivityError(e.toString()),
      );
    });
  }
}
