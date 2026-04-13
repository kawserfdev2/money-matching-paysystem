import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';

class SuperadminHeader extends StatelessWidget {
  final String title;
  const SuperadminHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mobile Menu Icon (Hidden on Large screens)
          if (MediaQuery.of(context).size.width < 1100)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),

          // Profile Section
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final userEmail = state is Authenticated
                  ? state.user.email
                  : 'Admin';

              return PopupMenuButton(
                offset: const Offset(0, 50),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Text(
                          'Super Admin',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent.shade100,
                      child: const Icon(Icons.person, color: Colors.blueAccent),
                    ),
                  ],
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Profile Settings'),
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                      context.go('/login');
                    },
                    child: const ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      dense: true,
                    ),
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
