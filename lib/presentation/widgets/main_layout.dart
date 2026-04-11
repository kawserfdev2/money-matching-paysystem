import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF1E293B), // Slate 900
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text(
            "AmarPay Admin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _buildNavItem(context, "Dashboard", Icons.dashboard_outlined, '/'),
          _buildNavItem(
            context,
            "Payments",
            Icons.payment_outlined,
            '/payments',
          ),
          _buildNavItem(
            context,
            "Gateways",
            Icons.account_balance_outlined,
            '/gateways',
          ),
          _buildNavItem(
            context,
            "Customers",
            Icons.people_outline,
            '/customers',
          ),
          _buildNavItem(
            context,
            "Settings",
            Icons.settings_outlined,
            '/settings',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    final bool isSelected = GoRouterState.of(context).matchedLocation == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
      ),
      onTap: () => context.go(route),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Welcome back",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String email = "";
              if (state is Authenticated) {
                email = state.email;
              }
              return Row(
                children: [
                  Text(email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
