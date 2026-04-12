import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/settings/settings_bloc.dart';
import '../../logic/settings/settings_event.dart';
import '../../logic/settings/settings_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/theme/theme_state.dart';
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
                color: Theme.of(context).colorScheme.surface,
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
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const ThemeSwitcher(),
          const SizedBox(width: 20),
          const Icon(Icons.notifications_none, color: Colors.grey),
          const SizedBox(width: 20),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => context.go(route),
        leading: Icon(
          icon,
          color: isActive ? colorScheme.primary : Colors.grey,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Row(
          children: [
            // Color Presets
            ...[
              const Color(0xFF2563EB), // Blue
              const Color(0xFF7C3AED), // Purple
              const Color(0xFF10B981), // Green
              const Color(0xFFF59E0B), // Amber
              const Color(0xFFEF4444), // Red
            ].map(
              (color) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () =>
                      context.read<ThemeBloc>().add(ChangePrimaryColor(color)),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: state.primaryColor == color
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (state.primaryColor == color)
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const VerticalDivider(width: 1, indent: 15, endIndent: 15),
            const SizedBox(width: 16),
            // Light/Dark Toggle
            IconButton(
              icon: Icon(
                state.themeMode == ThemeMode.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                size: 20,
              ),
              onPressed: () => context.read<ThemeBloc>().add(ToggleThemeMode()),
              tooltip: "Switch Theme",
            ),
          ],
        );
      },
    );
  }
}
