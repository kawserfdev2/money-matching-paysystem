import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/report/report_bloc.dart';
import '../../logic/report/report_state.dart';
import 'package:intl/intl.dart';
import 'responsive.dart';

class MetricCardGrid extends StatelessWidget {
  const MetricCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 4;
    double aspectRatio = 1.8;

    if (Responsive.isMobile(context)) {
      crossAxisCount = 1;
      aspectRatio = 2.5;
    } else if (Responsive.isTablet(context)) {
      crossAxisCount = 2;
      aspectRatio = 2.0;
    }

    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportLoaded) {
          final s = state.stats;
          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
            children: [
              _buildCard(context, "Today", s.todayRevenue, s.todayChange),
              _buildCard(
                context,
                "Yesterday",
                s.yesterdayRevenue,
                0,
                showChange: false,
              ),
              _buildCard(context, "This Week", s.thisWeekRevenue, s.weekChange),
              _buildCard(
                context,
                "Last Week",
                s.lastWeekRevenue,
                0,
                showChange: false,
              ),
              _buildCard(
                context,
                "This Month",
                s.thisMonthRevenue,
                s.monthChange,
              ),
              _buildCard(
                context,
                "Last Month",
                s.lastMonthRevenue,
                0,
                showChange: false,
              ),
              _buildCard(context, "This Year", s.thisYearRevenue, s.yearChange),
              _buildCard(
                context,
                "Last Year",
                s.lastYearRevenue,
                0,
                showChange: false,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    double amount,
    double change, {
    bool showChange = true,
  }) {
    final bool isPositive = change >= 0;
    final currencyFormat = NumberFormat.compactCurrency(symbol: '৳');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currencyFormat.format(amount),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showChange)
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${change.abs().toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
