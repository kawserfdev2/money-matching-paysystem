import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/superadmin/superadmin_repository.dart';
import '../../data/models/superadmin/platform_overview_model.dart';
import '../../data/models/superadmin/chart_data_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class SuperadminDashboardBloc
    extends Bloc<SuperadminDashboardEvent, SuperadminDashboardState> {
  final SuperadminRepository _repository;

  SuperadminDashboardBloc(this._repository) : super(OverviewInitial()) {
    on<FetchOverviewRequested>((event, emit) => _onFetchData(emit));
    on<RefreshDashboardData>((event, emit) => _onFetchData(emit));
  }

  Future<void> _onFetchData(Emitter<SuperadminDashboardState> emit) async {
    emit(OverviewLoading());
    try {
      debugPrint('🚀 [BLOC] Fetching superadmin dashboard overview data...');
      final results = await Future.wait([
        _repository.fetchPlatformOverview(),
        _repository.fetchChartData(),
      ]);

      final overview = results[0] as PlatformOverviewModel;
      final chartData = results[1] as List<ChartDataModel>;

      debugPrint('✅ [BLOC] Dashboard data loaded (Overview & Charts)');
      emit(OverviewLoaded(overview, chartData));
    } catch (e) {
      debugPrint('❌ [BLOC] Error fetching dashboard data: $e');
      emit(OverviewError(e.toString()));
    }
  }
}
