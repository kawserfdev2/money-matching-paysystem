import '../../data/models/superadmin/platform_overview_model.dart';
import '../../data/models/superadmin/chart_data_model.dart';

abstract class SuperadminDashboardState {}

class OverviewInitial extends SuperadminDashboardState {}

class OverviewLoading extends SuperadminDashboardState {}

class OverviewLoaded extends SuperadminDashboardState {
  final PlatformOverviewModel overview;
  final List<ChartDataModel> chartData;

  OverviewLoaded(this.overview, this.chartData);
}

class OverviewError extends SuperadminDashboardState {
  final String message;
  OverviewError(this.message);
}
