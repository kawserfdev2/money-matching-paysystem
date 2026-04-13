import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/superadmin/dashboard_bloc.dart';
import '../../../logic/superadmin/dashboard_event.dart';
import '../../../logic/superadmin/dashboard_state.dart';
import '../../../core/injection.dart';

class SuperadminDashboardPage extends StatelessWidget {
  const SuperadminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SuperadminDashboardBloc>()..add(FetchOverviewRequested()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Platform Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<SuperadminDashboardBloc, SuperadminDashboardState>(
                builder: (context, state) {
                  if (state is OverviewLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is OverviewError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is OverviewLoaded) {
                    final data = state.overview;
                    return GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width > 1200
                          ? 4
                          : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _MetricCard(
                          title: 'Total Merchants',
                          value: '${data.totalActiveMerchants}',
                          icon: Icons.storefront,
                          color: Colors.blue,
                        ),
                        _MetricCard(
                          title: 'Global Volume',
                          value:
                              '৳${data.totalPlatformVolume.toStringAsFixed(2)}',
                          icon: Icons.account_balance_wallet,
                          color: Colors.teal,
                        ),
                        _MetricCard(
                          title: 'Total Transactions',
                          value: '${data.totalTransactions}',
                          icon: Icons.receipt_long,
                          color: Colors.orange,
                        ),
                        _MetricCard(
                          title: 'Today\'s Volume',
                          value: '৳${data.todayVolume.toStringAsFixed(2)}',
                          icon: Icons.today,
                          color: Colors.purple,
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 40),
              // Future sections: Merchant Growth Chart, Recent Activity, etc.
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          LinearProgressIndicator(
            value: 0.7, // Demo value
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
