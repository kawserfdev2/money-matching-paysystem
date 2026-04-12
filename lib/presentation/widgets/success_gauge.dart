import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/report/report_bloc.dart';
import '../../logic/report/report_state.dart';

class SuccessGauge extends StatelessWidget {
  const SuccessGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Payment Success Rate",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const Spacer(),
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state is ReportLoaded) {
                return _buildGauge(context, state.stats.successRate);
              }
              return const CircularProgressIndicator();
            },
          ),
          const Spacer(),
          Text(
            "Successful vs Failed attempts across all gateways",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge(BuildContext context, double percentage) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 20,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            color: colorScheme.primary,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          children: [
            Text(
              "${percentage.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              "Success",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
