import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/automation/automation_bloc.dart';
import '../../logic/automation/automation_event.dart';
import '../../logic/automation/automation_state.dart';
import '../../domain/entities/sms_log_entity.dart';
import '../../core/injection.dart';

class SmsLogsPage extends StatelessWidget {
  const SmsLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AutomationBloc>()..add(WatchSmsLogs()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "MFS Automation",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
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
            _buildConnectedDevices(),
            Expanded(child: _buildLogsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDevices() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone_android, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "Connected Devices",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDeviceItem("Redmi Note 12", "Online", "Active now"),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(String name, String status, String lastSeen) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.smartphone, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                lastSeen,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
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
            padding: const EdgeInsets.all(24),
            itemCount: state.logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildLogCard(state.logs[index]),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLogCard(SmsLogEntity log) {
    final isMatched = log.status == 'matched';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isMatched
                ? Colors.blue.withOpacity(0.1)
                : Colors.amber.withOpacity(0.1),
            child: Icon(
              isMatched ? Icons.check_circle : Icons.warning,
              color: isMatched ? Colors.blue : Colors.amber,
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(log.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.body,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
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
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
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
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log.status.toUpperCase(),
              style: TextStyle(
                color: isMatched ? Colors.green : Colors.grey,
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
