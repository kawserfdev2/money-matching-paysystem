import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/dashboard_page.dart';
import '../../presentation/widgets/main_layout.dart';
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
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Payments Module Content')),
            ),
          ),
          GoRoute(
            path: '/gateways',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Gateways Module Content')),
            ),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Customers Module Content')),
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Settings Module Content')),
            ),
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
