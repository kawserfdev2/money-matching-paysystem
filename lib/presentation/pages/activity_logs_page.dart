import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/activity/activity_bloc.dart';
import '../../logic/activity/activity_event.dart';
import '../../logic/activity/activity_state.dart';
import '../../domain/entities/activity_entity.dart';
import '../../core/injection.dart';

class ActivityLogsPage extends StatelessWidget {
  const ActivityLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ActivityBloc>()..add(WatchActivityLogs()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Audit Trail",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, state) {
            if (state is ActivitiesLoaded) {
              if (state.activities.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No activities recorded yet",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: state.activities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 1),
                itemBuilder: (context, index) =>
                    _buildActivityItem(state.activities[index]),
              );
            }

            if (state is ActivityError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading activities:",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<ActivityBloc>().add(
                          WatchActivityLogs(),
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildActivityItem(ActivityEntity activity) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: const Icon(Icons.history, color: Colors.blue, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(
                        text: activity.userName ?? 'System',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " ${activity.action} "),
                      if (activity.resource != null)
                        TextSpan(
                          text: activity.resource!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(activity.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    const Text("•", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(
                      activity.ipAddress ?? 'N/A',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (activity.metadata.isNotEmpty)
            IconButton(
              onPressed: () {}, // Could show detail dialog
              icon: const Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
