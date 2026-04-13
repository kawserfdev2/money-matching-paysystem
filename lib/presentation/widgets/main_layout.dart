import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/settings/settings_bloc.dart';
import '../../logic/settings/settings_event.dart';
import '../../core/injection.dart';
import 'responsive.dart';
import 'side_menu.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/theme/theme_state.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(LoadSettings()),
      child: Scaffold(
        drawer: const Drawer(child: SideMenu()),
        body: Responsive(
          mobile: _MobileLayout(child: child),
          tablet: _MobileLayout(child: child),
          desktop: _DesktopLayout(child: child),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final Widget child;
  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 260, child: SideMenu()),
        Expanded(
          child: Column(
            children: [
              const _ImpersonationBanner(),
              const _Header(isDesktop: true),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final Widget child;
  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ImpersonationBanner(),
        const _Header(isDesktop: false),
        Expanded(child: child),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDesktop;
  const _Header({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isDesktop)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            )
          else
            const SizedBox.shrink(),
          Row(
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
        ],
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

class _ImpersonationBanner extends StatelessWidget {
  const _ImpersonationBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated && state.isImpersonating) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange.shade700,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "⚠️ You are currently impersonating a merchant. Any changes made here will affect their live account.",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(StopImpersonation());
                  },
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: const Text(
                    'Exit Impersonation',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(backgroundColor: Colors.black26),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
