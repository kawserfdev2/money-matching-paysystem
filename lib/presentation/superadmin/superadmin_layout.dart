import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/superadmin_sidebar.dart';
import 'widgets/superadmin_header.dart';

class SuperadminLayout extends StatelessWidget {
  final Widget child;
  const SuperadminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1100;

    // Determine title based on route
    final String location = GoRouterState.of(context).matchedLocation;
    String title = 'Dashboard';
    if (location.contains('merchants')) title = 'Merchant Management';
    if (location.contains('pricing')) title = 'Pricing Plans';
    if (location.contains('subscriptions')) title = 'Subscriptions';
    if (location.contains('settings')) title = 'Global Settings';
    if (location.contains('logs')) title = 'System Logs';

    return Scaffold(
      drawer: !isDesktop ? const Drawer(child: SuperadminSidebar()) : null,
      body: Row(
        children: [
          if (isDesktop) const SuperadminSidebar(),
          Expanded(
            child: Column(
              children: [
                SuperadminHeader(title: title),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC), // Light grey background
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
