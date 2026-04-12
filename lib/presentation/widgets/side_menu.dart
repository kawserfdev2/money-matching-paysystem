import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/settings/settings_bloc.dart';
import '../../logic/settings/settings_state.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).matchedLocation;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          _buildLogo(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(
                  context,
                  "Dashboard",
                  Icons.dashboard_outlined,
                  '/',
                  currentLocation == '/',
                ),
                _buildNavItem(
                  context,
                  "Payments",
                  Icons.payments_outlined,
                  '/payments',
                  currentLocation == '/payments',
                ),
                _buildNavItem(
                  context,
                  "Customers",
                  Icons.people_outline,
                  '/customers',
                  currentLocation == '/customers',
                ),
                _buildNavItem(
                  context,
                  "Gateways",
                  Icons.account_balance_outlined,
                  '/gateways',
                  currentLocation.startsWith('/gateways'),
                ),
                _buildNavItem(
                  context,
                  "Invoices",
                  Icons.receipt_long_outlined,
                  '/invoices',
                  currentLocation.startsWith('/invoices'),
                ),
                _buildNavItem(
                  context,
                  "Payment Links",
                  Icons.link,
                  '/payment-links',
                  currentLocation == '/payment-links',
                ),
                _buildNavItem(
                  context,
                  "Reports",
                  Icons.bar_chart_outlined,
                  '/reports',
                  currentLocation == '/reports',
                ),
                Divider(color: colorScheme.outlineVariant, height: 32),
                _buildNavItem(
                  context,
                  "SMS Automation",
                  Icons.phonelink_ring_outlined,
                  '/sms-logs',
                  currentLocation == '/sms-logs',
                ),
                _buildNavItem(
                  context,
                  "Developer",
                  Icons.code_outlined,
                  '/developer',
                  currentLocation == '/developer',
                ),
                _buildNavItem(
                  context,
                  "Audit Trail",
                  Icons.history,
                  '/activities',
                  currentLocation == '/activities',
                ),
                _buildNavItem(
                  context,
                  "Settings",
                  Icons.settings_outlined,
                  '/settings',
                  currentLocation == '/settings',
                ),
                const SizedBox(height: 16),
                _buildLogoutItem(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => _showLogoutDialog(context),
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
          size: 22,
        ),
        title: const Text(
          "Logout",
          style: TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dContext);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        String siteName = "AmarPay";
        String? logoUrl;

        if (state is SettingsLoaded) {
          siteName = state.brand.name;
          logoUrl = state.brand.logoUrl;
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: Row(
            children: [
              if (logoUrl != null && !logoUrl.contains("placehold"))
                Image.network(logoUrl, height: 32)
              else
                Image.asset('assets/logo.png', height: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  siteName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    bool isActive,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () {
          context.go(route);
          // Close drawer if open (handled by Scaffold)
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        },
        leading: Icon(
          icon,
          color: isActive ? colorScheme.primary : Colors.grey,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
