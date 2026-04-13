import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/superadmin/superadmin_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class SuperadminDashboardBloc
    extends Bloc<SuperadminDashboardEvent, SuperadminDashboardState> {
  final SuperadminRepository _repository;

  SuperadminDashboardBloc(this._repository) : super(OverviewInitial()) {
    on<FetchOverviewRequested>((event, emit) async {
      emit(OverviewLoading());
      try {
        final overview = await _repository.fetchPlatformOverview();
        emit(OverviewLoaded(overview));
      } catch (e) {
        emit(OverviewError(e.toString()));
      }
    });
  }
}
