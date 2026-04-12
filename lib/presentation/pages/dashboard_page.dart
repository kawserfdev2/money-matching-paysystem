import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/injection.dart';
import '../../logic/dashboard/dashboard_bloc.dart';
import '../../logic/dashboard/dashboard_event.dart';
import '../../logic/dashboard/dashboard_state.dart';
import '../widgets/dashboard_shimmer.dart';
import '../widgets/latest_payments_table.dart';
import '../widgets/payment_chart.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DashboardBloc>()..add(FetchDashboardData()),
      child: Scaffold(

        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const DashboardShimmer();
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text("Error: ${state.message}"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<DashboardBloc>().add(
                        FetchDashboardData(),
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Analytics Overview",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStatsGrid(state),
                    const SizedBox(height: 32),
                    PaymentChart(weeklyVolume: state.stats.weeklyVolume),
                    const SizedBox(height: 32),
                    LatestPaymentsTable(payments: state.latestPayments),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 2.5,
          children: [
            StatCard(
              title: "Total Payments",
              value: state.stats.totalPayments.toString(),
              icon: Icons.payments_outlined,
              iconColor: Colors.blue,
            ),
            StatCard(
              title: "Pending Payments",
              value: state.stats.pendingPayments.toString(),
              icon: Icons.pending_actions_outlined,
              iconColor: Colors.orange,
            ),
            StatCard(
              title: "Unpaid Invoices",
              value: state.stats.unpaidInvoices.toString(),
              icon: Icons.receipt_long_outlined,
              iconColor: Colors.red,
            ),
            StatCard(
              title: "Pending SMS",
              value: state.stats.pendingSms.toString(),
              icon: Icons.sms_outlined,
              iconColor: Colors.green,
            ),
          ],
        );
      },
    );
  }
}
