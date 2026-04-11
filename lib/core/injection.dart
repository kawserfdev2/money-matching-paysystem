import 'package:get_it/get_it.dart';
import '../domain/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../data/repositories/dashboard_repository_impl.dart';
import '../logic/auth/auth_bloc.dart';
import '../logic/dashboard/dashboard_bloc.dart';
import 'router/app_router.dart';

final getIt = GetIt.instance;

void setupInjection() {
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(),
  );

  // Blocs
  getIt.registerLazySingleton(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => DashboardBloc(getIt<DashboardRepository>()));

  // Router
  getIt.registerLazySingleton(() => AppRouter(getIt<AuthBloc>()));
}
