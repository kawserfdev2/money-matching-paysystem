import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../core/injection.dart';
import '../../../domain/entities/system_log_entity.dart';
import '../../../logic/superadmin/system_logs/system_logs_bloc.dart';
import '../../../logic/superadmin/system_logs/system_logs_event.dart';
import '../../../logic/superadmin/system_logs/system_logs_state.dart';

class SystemLogsPage extends StatelessWidget {
  const SystemLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SystemLogsBloc>()..add(const LoadLogs()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('System Logs & Health'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<SystemLogsBloc>().add(
                  const LoadLogs(isRefresh: true),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const _SystemLogsFilterBar(),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SystemLogsBloc, SystemLogsState>(
                  builder: (context, state) {
                    if (state is LogsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is LogsLoaded) {
                      if (state.logs.isEmpty) {
                        return const Center(
                          child: Text('No logs found matching filters.'),
                        );
                      }
                      return _LogsTable(logs: state.logs);
                    } else if (state is LogsError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemLogsFilterBar extends StatefulWidget {
  const _SystemLogsFilterBar();

  @override
  State<_SystemLogsFilterBar> createState() => _SystemLogsFilterBarState();
}

class _SystemLogsFilterBarState extends State<_SystemLogsFilterBar> {
  String _selectedLevel = 'all';
  String _selectedSource = 'all';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 20),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _selectedLevel,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Levels')),
                DropdownMenuItem(value: 'info', child: Text('Info')),
                DropdownMenuItem(value: 'warning', child: Text('Warning')),
                DropdownMenuItem(value: 'error', child: Text('Error')),
                DropdownMenuItem(value: 'critical', child: Text('Critical')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLevel = val);
                  context.read<SystemLogsBloc>().add(
                    FilterLogs(level: val, source: _selectedSource),
                  );
                }
              },
            ),
            const SizedBox(width: 24),
            DropdownButton<String>(
              value: _selectedSource,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Sources')),
                DropdownMenuItem(
                  value: 'payment_gateway',
                  child: Text('Payment Gateway'),
                ),
                DropdownMenuItem(value: 'webhook', child: Text('Webhook')),
                DropdownMenuItem(value: 'auth', child: Text('Auth')),
                DropdownMenuItem(
                  value: 'mfs_automation',
                  child: Text('MFS Automation'),
                ),
                DropdownMenuItem(
                  value: 'app_client',
                  child: Text('Application'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedSource = val);
                  context.read<SystemLogsBloc>().add(
                    FilterLogs(level: _selectedLevel, source: val),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LogsTable extends StatelessWidget {
  final List<SystemLogEntity> logs;
  const _LogsTable({required this.logs});

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 800,
      columns: const [
        DataColumn2(label: Text('Timestamp'), fixedWidth: 160),
        DataColumn2(label: Text('Level'), fixedWidth: 100),
        DataColumn2(label: Text('Source'), fixedWidth: 140),
        DataColumn2(label: Text('Message'), size: ColumnSize.L),
        DataColumn2(label: Text('Status'), fixedWidth: 100),
        DataColumn2(label: Text('Actions'), fixedWidth: 100),
      ],
      rows: logs.map((log) {
        return DataRow(
          cells: [
            DataCell(Text(DateFormat('dd MMM, hh:mm a').format(log.createdAt))),
            DataCell(_buildLevelBadge(log.level)),
            DataCell(Text(log.source)),
            DataCell(Text(log.message, overflow: TextOverflow.ellipsis)),
            DataCell(_buildStatusBadge(log.isResolved)),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    onPressed: () => _showLogDetails(context, log),
                    tooltip: 'View Details',
                  ),
                  if (!log.isResolved)
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: Colors.green,
                      ),
                      onPressed: () => context.read<SystemLogsBloc>().add(
                        MarkLogAsResolved(log.id),
                      ),
                      tooltip: 'Mark Resolved',
                    ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLevelBadge(String level) {
    Color color;
    switch (level.toLowerCase()) {
      case 'critical':
        color = Colors.red.shade900;
        break;
      case 'error':
        color = Colors.red;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      case 'info':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        level.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isResolved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isResolved
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isResolved ? Colors.green : Colors.orange),
      ),
      child: Text(
        isResolved ? 'Resolved' : 'Pending',
        style: TextStyle(
          color: isResolved ? Colors.green : Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, SystemLogEntity log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text('Log Details - ${log.level.toUpperCase()}'),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailItem('Message', log.message),
                _detailItem('Source', log.source),
                _detailItem(
                  'Timestamp',
                  DateFormat('dd MMMM yyyy, hh:mm:ss a').format(log.createdAt),
                ),
                if (log.merchantId != null)
                  _detailItem('Merchant ID', log.merchantId!),
                const SizedBox(height: 16),
                const Text(
                  'Metadata / Stack Trace:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    const JsonEncoder.withIndent('  ').convert(log.metadata),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
