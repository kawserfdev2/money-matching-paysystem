import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/dashboard_page.dart';
import '../../presentation/pages/gateway_list_page.dart';
import '../../presentation/pages/add_gateway_page.dart';
import '../../presentation/pages/payment_list_page.dart';
import '../../presentation/pages/customer_list_page.dart';
import '../../presentation/pages/invoice_list_page.dart';
import '../../presentation/pages/create_invoice_page.dart';
import '../../presentation/pages/payment_link_list_page.dart';
import '../../presentation/pages/public_checkout_page.dart';
import '../../presentation/pages/reports_page.dart';
import '../../presentation/pages/developer_settings_page.dart';
import '../../presentation/pages/brand_settings_page.dart';
import '../../presentation/pages/sms_logs_page.dart';
import '../../presentation/pages/activity_logs_page.dart';
import '../../presentation/widgets/main_layout.dart';
import '../../domain/entities/gateway_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _BlocToStream(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool registering = state.matchedLocation == '/register';
      final bool isPublic = state.matchedLocation.startsWith('/pay/');

      if (isPublic) return null; // Always allow public checkout routes

      if (authState is Unauthenticated) {
        if (loggingIn || registering) return null;
        return '/login';
      }

      if (authState is Authenticated) {
        if (loggingIn || registering) return '/';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/pay/:slug',
        builder: (context, state) =>
            PublicCheckoutPage(slug: state.pathParameters['slug']!),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentListPage(),
          ),
          GoRoute(
            path: '/gateways',
            builder: (context, state) => const GatewayListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddGatewayPage(),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    AddGatewayPage(editGateway: state.extra as GatewayEntity?),
              ),
            ],
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomerListPage(),
          ),
          GoRoute(
            path: '/invoices',
            builder: (context, state) => const InvoiceListPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateInvoicePage(),
              ),
            ],
          ),
          GoRoute(
            path: '/payment-links',
            builder: (context, state) => const PaymentLinkListPage(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/developer',
            builder: (context, state) => const DeveloperSettingsPage(),
          ),
          GoRoute(
            path: '/sms-logs',
            builder: (context, state) => const SmsLogsPage(),
          ),
          GoRoute(
            path: '/activities',
            builder: (context, state) => const ActivityLogsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const BrandSettingsPage(),
          ),
        ],
      ),
    ],
  );
}

class _BlocToStream extends ChangeNotifier {
  _BlocToStream(Bloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
