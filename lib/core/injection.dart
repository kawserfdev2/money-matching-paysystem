import 'package:get_it/get_it.dart';

// REPOSITORY INTERFACES
import 'package:amarpay/domain/repositories/auth_repository.dart';
import 'package:amarpay/domain/repositories/dashboard_repository.dart';
import 'package:amarpay/domain/repositories/gateway_repository.dart';
import 'package:amarpay/domain/repositories/payment_repository.dart';
import 'package:amarpay/domain/repositories/customer_repository.dart';
import 'package:amarpay/domain/repositories/invoice_repository.dart';
import 'package:amarpay/domain/repositories/payment_link_repository.dart';
import 'package:amarpay/domain/repositories/report_repository.dart';
import 'package:amarpay/domain/repositories/developer_repository.dart';
import 'package:amarpay/domain/repositories/automation_repository.dart';
import 'package:amarpay/domain/repositories/settings_repository.dart';
import 'package:amarpay/domain/repositories/activity_repository.dart';

// REPOSITORY IMPLEMENTATIONS
import 'package:amarpay/data/repositories/auth_repository_impl.dart';
import 'package:amarpay/data/repositories/dashboard_repository_impl.dart';
import 'package:amarpay/data/repositories/gateway_repository_impl.dart';
import 'package:amarpay/data/repositories/payment_repository_impl.dart';
import 'package:amarpay/data/repositories/customer_repository_impl.dart';
import 'package:amarpay/data/repositories/invoice_repository_impl.dart';
import 'package:amarpay/data/repositories/payment_link_repository_impl.dart';
import 'package:amarpay/data/repositories/report_repository_impl.dart';
import 'package:amarpay/data/repositories/developer_repository_impl.dart';
import 'package:amarpay/data/repositories/automation_repository_impl.dart';
import 'package:amarpay/data/repositories/settings_repository_impl.dart';
import 'package:amarpay/data/repositories/activity_repository_impl.dart';

// BLOCS
import 'package:amarpay/logic/auth/auth_bloc.dart';
import 'package:amarpay/logic/dashboard/dashboard_bloc.dart';
import 'package:amarpay/logic/gateway/gateway_bloc.dart';
import 'package:amarpay/logic/payment/payment_bloc.dart';
import 'package:amarpay/logic/customer/customer_bloc.dart';
import 'package:amarpay/logic/invoice/invoice_bloc.dart';
import 'package:amarpay/logic/payment_link/payment_link_bloc.dart';
import 'package:amarpay/logic/checkout/checkout_bloc.dart';
import 'package:amarpay/logic/report/report_bloc.dart';
import 'package:amarpay/logic/developer/developer_bloc.dart';
import 'package:amarpay/logic/automation/automation_bloc.dart';
import 'package:amarpay/logic/settings/settings_bloc.dart';
import 'package:amarpay/logic/activity/activity_bloc.dart';

import 'router/app_router.dart';

final getIt = GetIt.instance;

void setupInjection() {
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(),
  );
  getIt.registerLazySingleton<GatewayRepository>(() => GatewayRepositoryImpl());
  getIt.registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl());
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(),
  );
  getIt.registerLazySingleton<InvoiceRepository>(() => InvoiceRepositoryImpl());
  getIt.registerLazySingleton<PaymentLinkRepository>(
    () => PaymentLinkRepositoryImpl(),
  );
  getIt.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl());
  getIt.registerLazySingleton<DeveloperRepository>(
    () => DeveloperRepositoryImpl(),
  );

  getIt.registerLazySingleton<AutomationRepository>(
    () => AutomationRepositoryImpl(),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(),
  );
  getIt.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(),
  );

  // Blocs
  getIt.registerLazySingleton(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => DashboardBloc(getIt<DashboardRepository>()));
  getIt.registerFactory(() => GatewayBloc(getIt<GatewayRepository>()));
  getIt.registerFactory(() => PaymentBloc(getIt<PaymentRepository>()));
  getIt.registerFactory(() => CustomerBloc(getIt<CustomerRepository>()));
  getIt.registerFactory(() => InvoiceBloc(getIt<InvoiceRepository>()));
  getIt.registerFactory(() => PaymentLinkBloc(getIt<PaymentLinkRepository>()));
  getIt.registerFactory(
    () => CheckoutBloc(
      linkRepository: getIt<PaymentLinkRepository>(),
      gatewayRepository: getIt<GatewayRepository>(),
      paymentRepository: getIt<PaymentRepository>(),
    ),
  );
  getIt.registerFactory(() => ReportBloc(getIt<ReportRepository>()));
  getIt.registerFactory(() => DeveloperBloc(getIt<DeveloperRepository>()));
  getIt.registerFactory(
    () => AutomationBloc(
      getIt<AutomationRepository>(),
      getIt<ActivityRepository>(),
    ),
  );
  getIt.registerFactory(
    () =>
        SettingsBloc(getIt<SettingsRepository>(), getIt<ActivityRepository>()),
  );
  getIt.registerFactory(() => ActivityBloc(getIt<ActivityRepository>()));

  // Router
  getIt.registerLazySingleton(() => AppRouter(getIt<AuthBloc>()));
}
