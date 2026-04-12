import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/settings/settings_bloc.dart';
import '../../logic/settings/settings_event.dart';
import '../../logic/settings/settings_state.dart';
import '../../core/injection.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).matchedLocation;

    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(LoadSettings()),
      child: Scaffold(
        body: SelectionArea(
          child: Row(
            children: [
              // Sidebar
              Container(
                width: 260,
                color: const Color.fromARGB(255, 255, 255, 255),
                child: Column(
                  children: [
                    BlocBuilder<SettingsBloc, SettingsState>(
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
                              if (logoUrl != null &&
                                  !logoUrl.contains("placehold"))
                                Image.network(logoUrl, height: 32)
                              else
                                Image.asset('assets/logo.png', height: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  siteName,
                                  style: const TextStyle(
                                    color: Colors.black87,
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
                    ),
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
                          const Divider(color: Colors.white24, height: 32),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
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
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(Icons.notifications_none, color: Colors.grey),
          const SizedBox(width: 20),
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text("A", style: TextStyle(color: Colors.white)),
            ),
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
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => context.go(route),
        leading: Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.black54,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
