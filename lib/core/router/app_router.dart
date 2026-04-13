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

import '../../presentation/superadmin/superadmin_layout.dart';
import '../../presentation/pages/superadmin/merchants_page.dart';
import '../../presentation/pages/superadmin/pricing_page.dart';
import '../../presentation/pages/superadmin/settings_page.dart';
import '../../presentation/pages/superadmin/subscriptions_page.dart';
import '../../presentation/pages/superadmin/syslogs_page.dart';
import '../../presentation/pages/superadmin/dashboard_page.dart';

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
      final bool isSuperAdminRoute = state.matchedLocation.startsWith(
        '/superadmin',
      );

      if (isPublic) return null;

      // During initial session check or loading, don't redirect yet to avoid flash of login
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      if (authState is Unauthenticated) {
        if (loggingIn || registering) return null;
        // Strict redirect for baseurl or any protected route
        return '/login';
      }

      if (authState is Authenticated) {
        final role = authState.user.role;

        // If logged in and trying to access login/register, send to appropriate dashboard
        if (loggingIn || registering) {
          return role == 'superadmin' ? '/superadmin/dashboard' : '/';
        }

        // If hitting base path '/', redirect based on role
        if (state.matchedLocation == '/') {
          if (role == 'superadmin') return '/superadmin/dashboard';
        }

        // Protect superadmin routes
        if (isSuperAdminRoute && role != 'superadmin') {
          return '/';
        }

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

      // Superadmin Shell Route
      ShellRoute(
        builder: (context, state, child) => SuperadminLayout(child: child),
        routes: [
          GoRoute(
            path: '/superadmin/dashboard',
            builder: (context, state) => const SuperadminDashboardPage(),
          ),
          GoRoute(
            path: '/superadmin/merchants',
            builder: (context, state) => const MerchantManagementPage(),
          ),
          GoRoute(
            path: '/superadmin/pricing',
            builder: (context, state) => const PricingPlansPage(),
          ),
          GoRoute(
            path: '/superadmin/subscriptions',
            builder: (context, state) => const SubscriptionsPage(),
          ),
          GoRoute(
            path: '/superadmin/settings',
            builder: (context, state) => const GlobalSettingsPage(),
          ),
          GoRoute(
            path: '/superadmin/logs',
            builder: (context, state) => const SystemLogsPage(),
          ),
        ],
      ),

      // Merchant Shell Route
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
