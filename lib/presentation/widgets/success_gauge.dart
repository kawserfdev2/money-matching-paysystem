import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/report/report_bloc.dart';
import '../../logic/report/report_state.dart';
import 'dart:math' as math;

class SuccessGauge extends StatelessWidget {
  const SuccessGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Payment Success Rate",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state is ReportLoaded) {
                return _buildGauge(state.stats.successRate);
              }
              return const CircularProgressIndicator();
            },
          ),
          const Spacer(),
          const Text(
            "Successful vs Failed attempts across all gateways",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge(double percentage) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 20,
            backgroundColor: Colors.grey[100],
            color: Colors.blue,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          children: [
            Text(
              "${percentage.toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Success",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
