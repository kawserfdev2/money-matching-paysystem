import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../logic/superadmin/dashboard_bloc.dart';
import '../../../logic/superadmin/dashboard_event.dart';
import '../../../logic/superadmin/dashboard_state.dart';
import '../../../data/models/superadmin/platform_overview_model.dart';
import '../../../data/models/superadmin/chart_data_model.dart';
import '../../../core/injection.dart';

class SuperadminDashboardPage extends StatelessWidget {
  const SuperadminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<SuperadminDashboardBloc>()..add(FetchOverviewRequested()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<SuperadminDashboardBloc, SuperadminDashboardState>(
          builder: (context, state) {
            if (state is OverviewLoading || state is OverviewInitial) {
              return const _DashboardShimmer();
            }
            if (state is OverviewError) {
              return _ErrorWidget(
                message: state.message,
                onRetry: () {
                  debugPrint('🖱️ [UI] Retrying dashboard data fetch');
                  context.read<SuperadminDashboardBloc>().add(
                    RefreshDashboardData(),
                  );
                },
              );
            }
            if (state is OverviewLoaded) {
              return _DashboardContent(
                overview: state.overview,
                chartData: state.chartData,
                onRefresh: () {
                  debugPrint(
                    '🖱️ [UI] Refreshing dashboard data (via content)',
                  );
                  context.read<SuperadminDashboardBloc>().add(
                    RefreshDashboardData(),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─── Full Dashboard Content ─────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final PlatformOverviewModel overview;
  final List<ChartDataModel> chartData;
  final VoidCallback onRefresh;

  const _DashboardContent({
    required this.overview,
    required this.chartData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Platform Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // — Summary Cards (Responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxis = width > 1000 ? 4 : (width > 600 ? 2 : 1);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: width > 1000 ? 1.6 : 1.8,
                  children: [
                    _SummaryCard(
                      title: 'Active Merchants',
                      value: _formatNumber(
                        overview.totalActiveMerchants.toDouble(),
                      ),
                      icon: Icons.storefront_rounded,
                      color: const Color(0xFF7C3AED),
                      lightColor: const Color(0xFFF5F3FF),
                    ),
                    _SummaryCard(
                      title: 'Total Volume',
                      value: _formatCurrency(overview.totalPlatformVolume),
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFF2563EB),
                      lightColor: const Color(0xFFEFF6FF),
                    ),
                    _SummaryCard(
                      title: "Today's Volume",
                      value: _formatCurrency(overview.todayVolume),
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF059669),
                      lightColor: const Color(0xFFECFDF5),
                    ),
                    _SummaryCard(
                      title: 'Total Transactions',
                      value: _formatNumber(
                        overview.totalTransactions.toDouble(),
                      ),
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFFD97706),
                      lightColor: const Color(0xFFFFFBEB),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // — Chart
            _PlatformGrowthChart(chartData: chartData),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '৳${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '৳${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '৳${NumberFormat('#,##0.00').format(amount)}';
  }

  String _formatNumber(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return NumberFormat('#,##0').format(n);
  }
}

// ─── Summary Card ───────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Platform Growth Chart ──────────────────────────────────────

class _PlatformGrowthChart extends StatelessWidget {
  final List<ChartDataModel> chartData;

  const _PlatformGrowthChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = chartData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.volume))
        .toList();

    final maxY = chartData.map((e) => e.volume).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Growth (Last 30 Days)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (v, meta) {
                        if (v == 0 || v == maxY * 1.2) {
                          return const SizedBox.shrink();
                        }
                        final label = v >= 1000
                            ? '৳${(v / 1000).toStringAsFixed(0)}K'
                            : '৳${v.toStringAsFixed(0)}';
                        return Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= chartData.length) {
                          return const SizedBox.shrink();
                        }
                        final date = chartData[idx].date;
                        return Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF2563EB),
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2563EB).withOpacity(0.15),
                          const Color(0xFF2563EB).withOpacity(0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((s) {
                        final date = chartData[s.x.toInt()].date;
                        final formatted = DateFormat('dd MMM').format(date);
                        final amt = NumberFormat('#,##0.00').format(s.y);
                        return LineTooltipItem(
                          '$formatted\n৳$amt',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer Skeleton ───────────────────────────────────────────

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Card skeletons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: List.generate(4, (_) => _ShimmerBox(radius: 16)),
            ),
            const SizedBox(height: 28),
            // Chart skeleton
            _ShimmerBox(height: 300, radius: 16),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? height;
  final double radius;

  const _ShimmerBox({this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─── Error Widget ───────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
