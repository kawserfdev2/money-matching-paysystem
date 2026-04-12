import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/injection.dart';
import '../../logic/report/report_bloc.dart';
import '../../logic/report/report_event.dart';
import '../../logic/report/report_state.dart';
import '../widgets/responsive.dart';
import '../widgets/metric_card_grid.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/success_gauge.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReportBloc>()..add(FetchReportStats()),
      child: Scaffold(
        body: BlocConsumer<ReportBloc, ReportState>(
          listener: (context, state) {
            if (state is ReportError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      Text(
                        "Financial Analytics",
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      _buildFilterBar(context, state),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Summary Cards Grid
                  const MetricCardGrid(),
                  const SizedBox(height: 32),

                  if (Responsive.isDesktop(context))
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(flex: 2, child: RevenueChart()),
                        const SizedBox(width: 24),
                        const Expanded(flex: 1, child: SuccessGauge()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const RevenueChart(),
                        const SizedBox(height: 24),
                        const SuccessGauge(),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, ReportState state) {
    DateTime start = DateTime.now().subtract(const Duration(days: 30));
    DateTime end = DateTime.now();

    if (state is ReportLoaded && state.startDate != null) {
      start = state.startDate!;
      end = state.endDate!;
    }

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: DateTimeRange(start: start, end: end),
            );
            if (range != null) {
              context.read<ReportBloc>().add(
                FilterReportByDate(range.start, range.end),
              );
            }
          },
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            state is ReportLoaded && state.startDate != null
                ? "${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}"
                : "Custom Range",
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
       // const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            context.read<ReportBloc>().add(ExportReport(start, end));
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text("Export Report"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
