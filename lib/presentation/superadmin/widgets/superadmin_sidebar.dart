import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuperadminSidebar extends StatelessWidget {
  const SuperadminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 280,
      color: const Color(0xFF0F172A), // Deep Navy
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _MenuItem(
                  title: 'Overview',
                  icon: Icons.dashboard_outlined,
                  route: '/superadmin/dashboard',
                  isActive: currentRoute == '/superadmin/dashboard',
                ),
                _MenuItem(
                  title: 'Merchants',
                  icon: Icons.storefront_outlined,
                  route: '/superadmin/merchants',
                  isActive: currentRoute == '/superadmin/merchants',
                ),
                _MenuItem(
                  title: 'Pricing Plans',
                  icon: Icons.price_change_outlined,
                  route: '/superadmin/pricing',
                  isActive: currentRoute == '/superadmin/pricing',
                ),
                _MenuItem(
                  title: 'Subscriptions',
                  icon: Icons.autorenew,
                  route: '/superadmin/subscriptions',
                  isActive: currentRoute == '/superadmin/subscriptions',
                ),
                _MenuItem(
                  title: 'Global Settings',
                  icon: Icons.settings_applications_outlined,
                  route: '/superadmin/settings',
                  isActive: currentRoute == '/superadmin/settings',
                ),
                _MenuItem(
                  title: 'System Logs',
                  icon: Icons.terminal_outlined,
                  route: '/superadmin/logs',
                  isActive: currentRoute == '/superadmin/logs',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Paymently Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final bool isActive;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () => context.go(route),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey.shade400,
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade400,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          tileColor: isActive ? Colors.blueAccent.withOpacity(0.1) : null,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
