import '../../data/models/superadmin/platform_overview_model.dart';

abstract class SuperadminDashboardState {}

class OverviewInitial extends SuperadminDashboardState {}

class OverviewLoading extends SuperadminDashboardState {}

class OverviewLoaded extends SuperadminDashboardState {
  final PlatformOverviewModel overview;
  OverviewLoaded(this.overview);
}

class OverviewError extends SuperadminDashboardState {
  final String message;
  OverviewError(this.message);
}
