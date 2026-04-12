import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/automation/automation_bloc.dart';
import '../../logic/automation/automation_event.dart';
import '../../logic/automation/automation_state.dart';
import '../../domain/entities/sms_log_entity.dart';
import '../../core/injection.dart';
import '../widgets/responsive.dart';

class SmsLogsPage extends StatelessWidget {
  const SmsLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AutomationBloc>()..add(WatchSmsLogs()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "MFS Automation",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: () => _showManualSyncDialog(context),
              icon: const Icon(Icons.sync),
              label: const Text("Manual Sync"),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildConnectedDevices(context),
            Expanded(child: _buildLogsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDevices(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = Responsive.isMobile(context) ? 16.0 : 24.0;
    return Container(
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_android, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                "Connected Devices",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDeviceItem(context, "Redmi Note 12", "Online", "Active now"),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context,
    String name,
    String status,
    String lastSeen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.smartphone, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                lastSeen,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogsList() {
    return BlocBuilder<AutomationBloc, AutomationState>(
      builder: (context, state) {
        if (state is SmsLogsLoaded) {
          return ListView.separated(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
            itemCount: state.logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildLogCard(context, state.logs[index]),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLogCard(BuildContext context, SmsLogEntity log) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMatched = log.status == 'matched';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isMatched
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.secondary.withValues(alpha: 0.1),
            child: Icon(
              isMatched ? Icons.check_circle : Icons.warning,
              color: isMatched ? colorScheme.primary : colorScheme.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.sender,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(log.createdAt),
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.body,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (log.amount != null) ...[
                      Text(
                        "৳${log.amount}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (log.trxId != null) ...[
                      Text(
                        "TrxID: ${log.trxId}",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isMatched
                  ? Colors.green.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log.status.toUpperCase(),
              style: TextStyle(
                color: isMatched ? Colors.green : colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualSyncDialog(BuildContext context) {
    final bodyController = TextEditingController();
    final senderController = TextEditingController();

    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text("Manual SMS Sync"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: senderController,
              decoration: const InputDecoration(
                labelText: "Sender (e.g. bKash)",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: "SMS Body"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AutomationBloc>().add(
                SyncSmsManually(bodyController.text, senderController.text),
              );
              Navigator.pop(dContext);
            },
            child: const Text("Sync Now"),
          ),
        ],
      ),
    );
  }
}
