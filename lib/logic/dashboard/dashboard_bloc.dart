import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;
  StreamSubscription? _paymentSubscription;

  DashboardBloc(this._repository) : super(DashboardInitial()) {
    on<FetchDashboardData>((event, emit) async {
      emit(DashboardLoading());
      try {
        final stats = await _repository.getDashboardStats();
        final latestPayments = await _repository.getLatestPayments();
        emit(DashboardLoaded(stats: stats, latestPayments: latestPayments));

        // Start listening to real-time updates
        _paymentSubscription?.cancel();
        _paymentSubscription = _repository.watchPayments().listen((payments) {
          add(UpdateRealtimeStats(payments));
        });
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    });

    on<UpdateRealtimeStats>((event, emit) async {
      if (state is DashboardLoaded) {
        // When payments change, we also refresh overall stats to be safe
        final stats = await _repository.getDashboardStats();
        emit(
          DashboardLoaded(stats: stats, latestPayments: event.latestPayments),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _paymentSubscription?.cancel();
    return super.close();
  }
}
